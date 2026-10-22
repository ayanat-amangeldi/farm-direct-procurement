import 'dart:async';
import 'dart:convert';
import 'package:farm_direct/catalog/demo_catalog.dart';
import 'package:farm_direct/catalog/models.dart';
import 'package:farm_direct/orders/order.dart';
import 'package:farm_direct/orders/order_store.dart';
import 'package:flutter_test/flutter_test.dart';

final product = DemoCatalog.products.first;
final offer = DemoCatalog.offers[2];

Future<ProcurementOrder> place(
  OrderStore store, {
  int kg = 50,
  bool delivery = true,
  String name = 'Demo Buyer',
  String phone = '+7 700 000 00 00',
  String address = 'Demo city, Sample Street 1',
  FarmerOffer? selectedOffer,
}) => store.place(
  product: product,
  offer: selectedOffer ?? offer,
  kg: kg,
  delivery: delivery,
  contactName: name,
  phone: phone,
  address: address,
  note: 'Sample order',
);

class FailingPersistence extends MemoryOrderPersistence {
  @override
  Future<void> write(String value) async => throw StateError('Storage full');
}

class DelayedPersistence extends MemoryOrderPersistence {
  final gate = Completer<void>();
  @override
  Future<void> write(String value) async {
    await gate.future;
    await super.write(value);
  }
}

void main() {
  test(
    'saved terms, date and stock survive restoration; IDs stay unique',
    () async {
      final persistence = MemoryOrderPersistence();
      final time = DateTime.utc(2026, 10, 23, 8, 30);
      final store = OrderStore(persistence: persistence, now: () => time);
      final order = await place(store);
      expect(order.total, 12000);
      expect(order.unitPrice, 190);
      expect(order.deliveryFee, 2500);
      expect(order.createdAt, time);
      expect(order.status, OrderStatus.pending);
      expect(store.availableKg(offer), 750);
      final restored = await OrderStore.restore(persistence);
      expect(restored.orders.single.toJson(), order.toJson());
      expect(restored.availableKg(offer), 750);
      expect(restored.sessionOnly, isFalse);
      final second = await place(restored, delivery: false);
      expect(second.id, 'FD-0002');
      expect(second.total, 9500);
      expect(second.address, isEmpty);
      expect(restored.find(order.id)!.total, 12000);
    },
  );

  test(
    'orders cannot oversell and cancellation releases stock without changing price',
    () async {
      final store = OrderStore();
      final order = await place(store, kg: 760);
      expect(store.availableKg(offer), 40);
      await expectLater(place(store), throwsA(isA<OrderException>()));
      expect(store.orders, hasLength(1));
      await store.cancel(order.id);
      expect(store.availableKg(offer), 800);
      expect(store.find(order.id)!.status, OrderStatus.cancelled);
      expect(store.find(order.id)!.total, order.total);
      await expectLater(store.cancel(order.id), throwsA(isA<OrderException>()));
      final newOrder = await place(store, kg: 800);
      expect(store.availableKg(offer), 0);
      expect(newOrder.id, 'FD-0002');
    },
  );

  test(
    'a storage failure creates neither an order nor a stock reservation',
    () async {
      final store = OrderStore(persistence: FailingPersistence());
      await expectLater(place(store), throwsA(isA<OrderException>()));
      expect(store.orders, isEmpty);
      expect(store.availableKg(offer), 800);
      // The failed attempt releases the write lock as well.
      await expectLater(place(store), throwsA(isA<OrderException>()));
    },
  );

  test(
    'concurrent clicks cannot write duplicate orders or lose a reservation',
    () async {
      final persistence = DelayedPersistence();
      final store = OrderStore(persistence: persistence);
      final first = place(store);
      await expectLater(place(store), throwsA(isA<OrderException>()));
      expect(store.orders, isEmpty);
      persistence.gate.complete();
      await first;
      expect(store.orders, hasLength(1));
      expect(store.availableKg(offer), 750);
    },
  );

  test(
    'invalid contact, fulfillment and mismatched product are rejected',
    () async {
      final store = OrderStore();
      for (final attempt in [
        () => place(store, name: ' '),
        () => place(store, phone: 'abc'),
        () => place(store, address: ' '),
        () => place(store, kg: 49),
        () => place(store, selectedOffer: DemoCatalog.offers.first),
        () => place(store, selectedOffer: DemoCatalog.offers[3]),
      ]) {
        await expectLater(attempt(), throwsA(isA<OrderException>()));
      }
      expect(store.orders, isEmpty);
    },
  );

  test(
    'failed cancellation retains the existing order and reserved stock',
    () async {
      final memory = MemoryOrderPersistence();
      final initial = OrderStore(persistence: memory);
      final order = await place(initial);
      final failing = FailingPersistence()..value = memory.value;
      final store = await OrderStore.restore(failing);
      await expectLater(store.cancel(order.id), throwsA(isA<OrderException>()));
      expect(store.find(order.id)!.status, OrderStatus.pending);
      expect(store.availableKg(offer), 750);
      expect(failing.value, memory.value);
    },
  );

  test(
    'unreadable, unknown-version or duplicate history is never overwritten',
    () async {
      final good = MemoryOrderPersistence();
      await place(OrderStore(persistence: good));
      final data = jsonDecode(good.value!) as Map<String, dynamic>;
      final order = (data['orders'] as List).single;
      for (final raw in [
        '{broken',
        jsonEncode({'version': 2, 'orders': []}),
        jsonEncode({
          'version': 1,
          'orders': [order, order],
        }),
      ]) {
        final persistence = MemoryOrderPersistence()..value = raw;
        await expectLater(
          OrderStore.restore(persistence),
          throwsA(isA<FormatException>()),
        );
        expect(persistence.value, raw);
      }
    },
  );
}
