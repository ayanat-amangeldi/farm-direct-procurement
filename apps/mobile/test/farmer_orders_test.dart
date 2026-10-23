import 'dart:convert';
import 'package:farm_direct/catalog/demo_catalog.dart';
import 'package:farm_direct/main.dart';
import 'package:farm_direct/orders/order.dart';
import 'package:farm_direct/orders/order_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'checkout_test.dart' show tapVisible, reveal;
import 'order_store_test.dart'
    show place, FailingPersistence, DelayedPersistence;

void main() {
  test(
    'farm confirmation persists fixed terms and does not reserve stock twice',
    () async {
      final persistence = MemoryOrderPersistence();
      var now = DateTime.utc(2026, 10, 23, 10);
      final store = OrderStore(persistence: persistence, now: () => now);
      final order = await place(store);
      final remaining = store.availableKg(DemoCatalog.offers[2]);
      now = now.add(const Duration(minutes: 5));
      await store.confirm(order.id, farmId: 'bereke');
      final confirmed = store.find(order.id)!;
      expect(confirmed.status, OrderStatus.confirmed);
      expect(confirmed.confirmedAt, now);
      final terms = confirmed.toJson()
        ..remove('status')
        ..remove('confirmedAt');
      expect(
        terms,
        order.toJson()
          ..remove('status')
          ..remove('confirmedAt'),
      );
      expect(store.availableKg(DemoCatalog.offers[2]), remaining);
      final restored = await OrderStore.restore(persistence);
      expect(restored.find(order.id)!.toJson(), confirmed.toJson());
      await expectLater(
        restored.cancel(order.id),
        throwsA(isA<OrderException>()),
      );
      await expectLater(
        restored.confirm(order.id, farmId: 'bereke'),
        throwsA(isA<OrderException>()),
      );
    },
  );

  test('farms see and confirm only their own awaiting orders', () async {
    final store = OrderStore();
    final order = await place(store);
    final other = await place(
      store,
      delivery: false,
      selectedOffer: DemoCatalog.offers.first,
    );
    expect(store.ordersForFarm('bereke').map((order) => order.id), [order.id]);
    expect(store.ordersForFarm('saryarka').map((order) => order.id), [
      other.id,
    ]);
    expect(store.ordersForFarm(''), isEmpty);
    for (final id in ['', 'saryarka', 'unknown']) {
      await expectLater(
        store.confirm(order.id, farmId: id),
        throwsA(isA<OrderException>()),
      );
    }
    await expectLater(
      store.confirm('missing', farmId: 'bereke'),
      throwsA(isA<OrderException>()),
    );
    expect(store.find(order.id)!.status, OrderStatus.pending);
    await store.cancel(order.id);
    await expectLater(
      store.confirm(order.id, farmId: 'bereke'),
      throwsA(isA<OrderException>()),
    );
  });

  test(
    'failed confirmation leaves pending state, terms and saved data unchanged',
    () async {
      final memory = MemoryOrderPersistence();
      final order = await place(OrderStore(persistence: memory));
      final failing = FailingPersistence()..value = memory.value;
      final store = await OrderStore.restore(failing);
      await expectLater(
        store.confirm(order.id, farmId: 'bereke'),
        throwsA(isA<OrderException>()),
      );
      expect(store.find(order.id)!.toJson(), order.toJson());
      expect(failing.value, memory.value);
    },
  );

  test(
    'confirmation wins a concurrent cancellation without lost updates',
    () async {
      final memory = MemoryOrderPersistence();
      final order = await place(OrderStore(persistence: memory));
      final delayed = DelayedPersistence()..value = memory.value;
      final store = await OrderStore.restore(delayed);
      final confirmation = store.confirm(order.id, farmId: 'bereke');
      await expectLater(store.cancel(order.id), throwsA(isA<OrderException>()));
      delayed.gate.complete();
      await confirmation;
      expect(store.find(order.id)!.status, OrderStatus.confirmed);
    },
  );

  test(
    'legacy history resolves ownership by known offer ID without erasing orders',
    () async {
      final memory = MemoryOrderPersistence();
      final order = await place(OrderStore(persistence: memory));
      final legacy = order.toJson()
        ..remove('farmId')
        ..remove('confirmedAt');
      memory.value = jsonEncode({
        'version': 1,
        'orders': [legacy],
      });
      final restored = await OrderStore.restore(memory);
      expect(restored.ordersForFarm('bereke').single.id, order.id);
      await restored.confirm(order.id, farmId: 'bereke');
      expect(restored.find(order.id)!.total, 12000);
      legacy['offerId'] = 'removed-offer';
      memory.value = jsonEncode({
        'version': 1,
        'orders': [legacy],
      });
      final unknown = await OrderStore.restore(memory);
      expect(unknown.orders, hasLength(1));
      expect(unknown.ordersForFarm('bereke'), isEmpty);
      expect(unknown.ordersForFarm(''), isEmpty);
      await expectLater(
        unknown.confirm(order.id, farmId: 'bereke'),
        throwsA(isA<OrderException>()),
      );
    },
  );

  testWidgets(
    'farmer filters orders, confirms and buyer sees persisted status',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final persistence = MemoryOrderPersistence();
      final store = OrderStore(persistence: persistence);
      final order = await place(store);
      final other = await place(
        store,
        delivery: false,
        selectedOffer: DemoCatalog.offers.first,
      );
      await tester.pumpWidget(FarmDirectApp(orderStore: store));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('open-farmer-workspace')));
      expect(find.text('Awaiting (1)'), findsOneWidget);
      expect(find.byKey(Key('farmer-order-${other.id}')), findsNothing);
      await tapVisible(tester, find.byKey(Key('farmer-order-${order.id}')));
      await tapVisible(tester, find.byKey(const Key('confirm-farmer-order')));
      expect(find.text('Confirm this demo order?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Back'));
      await tester.pumpAndSettle();
      expect(store.find(order.id)!.status, OrderStatus.pending);
      await tapVisible(tester, find.byKey(const Key('confirm-farmer-order')));
      await tester.tap(find.text('Confirm order'));
      await tester.pumpAndSettle();
      expect(store.find(order.id)!.status, OrderStatus.confirmed);
      expect(find.byKey(const Key('confirm-farmer-order')), findsNothing);
      expect(find.byKey(const Key('cancel-order')), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Confirmed (1)'));
      await reveal(tester, find.byKey(Key('farmer-order-${order.id}')));
      await tester.scrollUntilVisible(
        find.byKey(const Key('farmer-selector')),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('farmer-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saryarka Farm').last);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Awaiting (1)'));
      expect(find.byKey(Key('farmer-order-${order.id}')), findsNothing);
      await reveal(tester, find.byKey(Key('farmer-order-${other.id}')));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      final restored = await OrderStore.restore(persistence);
      await tester.pumpWidget(FarmDirectApp(orderStore: restored));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-orders')));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(Key('order-${order.id}')));
      await reveal(tester, find.text('Confirmed'));
      expect(find.text('Confirmed'), findsOneWidget);
      await reveal(tester, find.byKey(const Key('order-confirmed-at')));
      expect(find.byKey(const Key('order-confirmed-at')), findsOneWidget);
      expect(find.byKey(const Key('cancel-order')), findsNothing);
      await reveal(tester, find.byKey(const Key('saved-order-total')));
      expect(
        tester.widget<Text>(find.byKey(const Key('saved-order-total'))).data,
        '₸12 000',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'farmer empty state remains usable with narrow screen and larger text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(320, 720),
              textScaler: TextScaler.linear(1.5),
            ),
            child: FarmDirectApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('open-farmer-workspace')));
      await reveal(tester, find.text('No orders for this farm yet'));
      expect(tester.takeException(), isNull);
      await tapVisible(tester, find.text('Back to buyer catalog'));
      expect(find.byKey(const Key('catalog-search')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
