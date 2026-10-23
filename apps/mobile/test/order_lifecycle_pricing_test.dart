import 'auth_helpers.dart';
import 'dart:convert';
import 'package:farm_direct/catalog/demo_catalog.dart';
import 'package:farm_direct/main.dart';
import 'package:farm_direct/orders/order.dart';
import 'package:farm_direct/orders/order_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'order_store_test.dart'
    show place, FailingPersistence, DelayedPersistence;
import 'offer_management_test.dart' show draft, tap, reach;
import 'catalog_test.dart' show openPotatoes;

Map<String, Object?> terms(ProcurementOrder order) =>
    order.toJson()..removeWhere(
      (key, _) => {
        'status',
        'confirmedAt',
        'readyAt',
        'completedAt',
        'rejectedAt',
        'cancelledAt',
        'rejectionReason',
      }.contains(key),
    );

void main() {
  test(
    'pickup and delivery complete in sequence with saved dates, fixed terms and consumed stock',
    () async {
      for (final delivery in [false, true]) {
        final memory = MemoryOrderPersistence();
        var time = DateTime.utc(2026, 10, 23, 10);
        final store = await farmerStore(
          OrderStore(persistence: memory, now: () => time),
        );
        final order = await place(store, delivery: delivery);
        final expectedTerms = terms(order);
        time = time.add(const Duration(minutes: 1));
        await store.confirm(order.id, farmId: 'bereke');
        final confirmedAt = time;
        time = time.add(const Duration(minutes: 1));
        await store.markReady(order.id, farmId: 'bereke');
        final readyAt = time;
        time = time.add(const Duration(minutes: 1));
        await store.complete(order.id, farmId: 'bereke');
        final saved = store.find(order.id)!;
        expect(saved.status, OrderStatus.completed);
        expect(saved.confirmedAt, confirmedAt);
        expect(saved.readyAt, readyAt);
        expect(saved.completedAt, time);
        expect(saved.isActive, isFalse);
        expect(terms(saved), expectedTerms);
        expect(store.availableKg(DemoCatalog.offers[2]), 750);
        final restored = await farmerStore(await OrderStore.restore(memory));
        expect(restored.find(order.id)!.toJson(), saved.toJson());
      }
    },
  );

  test(
    'cannot skip stages, act for another farm or reopen terminal orders',
    () async {
      final store = await farmerStore(OrderStore());
      final order = await place(store);
      for (final action in [
        () => store.markReady(order.id, farmId: 'bereke'),
        () => store.complete(order.id, farmId: 'bereke'),
        () => store.reject(
          order.id,
          farmId: 'saryarka',
          reason: 'No available stock',
        ),
        () => store.reject(order.id, farmId: 'bereke', reason: '  '),
        () => store.reject(order.id, farmId: 'bereke', reason: 'x' * 301),
      ]) {
        await expectLater(action(), throwsA(isA<OrderException>()));
      }
      await store.confirm(order.id, farmId: 'bereke');
      await expectLater(
        store.complete(order.id, farmId: 'bereke'),
        throwsA(isA<OrderException>()),
      );
      await expectLater(
        store.markReady(order.id, farmId: 'saryarka'),
        throwsA(isA<OrderException>()),
      );
      await store.markReady(order.id, farmId: 'bereke');
      await expectLater(
        store.reject(order.id, farmId: 'bereke', reason: 'Changed plans'),
        throwsA(isA<OrderException>()),
      );
      await store.complete(order.id, farmId: 'bereke');
      for (final action in [
        () => store.confirm(order.id, farmId: 'bereke'),
        () => store.markReady(order.id, farmId: 'bereke'),
        () => store.complete(order.id, farmId: 'bereke'),
        () => store.reject(
          order.id,
          farmId: 'bereke',
          reason: 'No available stock',
        ),
        () => store.cancel(order.id),
      ]) {
        await expectLater(action(), throwsA(isA<OrderException>()));
      }
      expect(store.find(order.id)!.status, OrderStatus.completed);
    },
  );

  test(
    'rejection before readiness preserves the reason and terms and releases stock once',
    () async {
      for (final confirmed in [false, true]) {
        final memory = MemoryOrderPersistence();
        final store = await farmerStore(OrderStore(persistence: memory));
        final order = await place(store);
        if (confirmed) await store.confirm(order.id, farmId: 'bereke');
        await store.reject(
          order.id,
          farmId: 'bereke',
          reason: '  Harvest damaged during packing.  ',
        );
        final rejected = store.find(order.id)!;
        expect(rejected.status, OrderStatus.rejected);
        expect(rejected.rejectionReason, 'Harvest damaged during packing.');
        expect(rejected.rejectedAt, isNotNull);
        expect(rejected.confirmedAt != null, confirmed);
        expect(rejected.isActive, isFalse);
        expect(terms(rejected), terms(order));
        expect(store.availableKg(DemoCatalog.offers[2]), 800);
        await expectLater(
          store.reject(order.id, farmId: 'bereke', reason: 'Other reason'),
          throwsA(isA<OrderException>()),
        );
        final restored = await farmerStore(await OrderStore.restore(memory));
        expect(restored.find(order.id)!.toJson(), rejected.toJson());
      }
    },
  );

  test(
    'failed transitions do not alter status, timestamps, reason or stock',
    () async {
      for (final source in [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.ready,
      ]) {
        final memory = MemoryOrderPersistence();
        final initial = await farmerStore(OrderStore(persistence: memory));
        final order = await place(initial);
        if (source != OrderStatus.pending) {
          await initial.confirm(order.id, farmId: 'bereke');
        }
        if (source == OrderStatus.ready) {
          await initial.markReady(order.id, farmId: 'bereke');
        }
        final failing = FailingPersistence()..value = memory.value;
        final store = await farmerStore(await OrderStore.restore(failing));
        final before = store.find(order.id)!.toJson();
        final action = switch (source) {
          OrderStatus.pending => store.reject(
            order.id,
            farmId: 'bereke',
            reason: 'No available stock',
          ),
          OrderStatus.confirmed => store.markReady(order.id, farmId: 'bereke'),
          _ => store.complete(order.id, farmId: 'bereke'),
        };
        await expectLater(action, throwsA(isA<OrderException>()));
        expect(store.find(order.id)!.toJson(), before);
        expect(store.availableKg(DemoCatalog.offers[2]), 750);
        expect(failing.value, memory.value);
      }
    },
  );

  test(
    'a concurrent rejection cannot overwrite a successful readiness change',
    () async {
      final memory = MemoryOrderPersistence();
      final initial = await farmerStore(OrderStore(persistence: memory));
      final order = await place(initial);
      await initial.confirm(order.id, farmId: 'bereke');
      final delayed = DelayedPersistence()..value = memory.value;
      final store = await farmerStore(await OrderStore.restore(delayed));
      final ready = store.markReady(order.id, farmId: 'bereke');
      await expectLater(
        store.reject(order.id, farmId: 'bereke', reason: 'No available stock'),
        throwsA(isA<OrderException>()),
      );
      delayed.gate.complete();
      await ready;
      expect(store.find(order.id)!.status, OrderStatus.ready);
      expect(store.availableKg(DemoCatalog.offers[2]), 750);
    },
  );

  test(
    'price log records publication, increases, decreases and delivery changes only after saving',
    () async {
      final memory = MemoryOrderPersistence();
      var time = DateTime.utc(2026, 10, 23, 10);
      final store = await farmerStore(
        OrderStore(persistence: memory, now: () => time),
      );
      final order = await place(store);
      expect(store.priceHistoryFor('potato-3'), isEmpty);
      await store.saveOffer(
        farmId: 'bereke',
        offerId: 'potato-3',
        draft: draft(productId: 'potatoes', price: 240, fee: 700),
      );
      final increase = store.priceHistoryFor('potato-3').single;
      expect(increase.at, time);
      expect([increase.oldPrice, increase.newPrice], [190, 240]);
      expect([increase.oldDeliveryFee, increase.newDeliveryFee], [2500, 700]);
      time = time.add(const Duration(minutes: 2));
      await store.saveOffer(
        farmId: 'bereke',
        offerId: 'potato-3',
        draft: draft(productId: 'potatoes', price: 220, fee: 700),
      );
      await store.saveOffer(
        farmId: 'bereke',
        offerId: 'potato-3',
        draft: draft(productId: 'potatoes', price: 220, fee: 0),
      );
      expect(store.priceHistoryFor('potato-3').first.deliveryChanged, isTrue);
      expect(store.priceHistoryFor('potato-3').first.unitChanged, isFalse);
      await store.saveOffer(
        farmId: 'bereke',
        offerId: 'potato-3',
        draft: draft(productId: 'potatoes', price: 220, fee: 0, stock: 200),
      );
      expect(store.priceHistoryFor('potato-3'), hasLength(3));
      final published = await store.saveOffer(farmId: 'bereke', draft: draft());
      expect(store.priceHistoryFor(published.id).single.published, isTrue);
      expect(store.find(order.id)!.total, 12000);
      final restored = await farmerStore(await OrderStore.restore(memory));
      expect(
        restored
            .priceHistoryFor('potato-3')
            .map((item) => item.toJson())
            .toList(),
        store.priceHistoryFor('potato-3').map((item) => item.toJson()).toList(),
      );
      final failing = FailingPersistence()..value = memory.value;
      final failed = await farmerStore(await OrderStore.restore(failing));
      await expectLater(
        failed.saveOffer(
          farmId: 'bereke',
          offerId: 'potato-3',
          draft: draft(productId: 'potatoes', price: 300),
        ),
        throwsA(isA<OrderException>()),
      );
      expect(failed.priceHistoryFor('potato-3'), hasLength(3));
      expect(failed.offer('potato-3')!.pricePerKg, 220);
      expect(failing.value, memory.value);
    },
  );

  test(
    'old saves acquire no invented price dates and invalid history remains untouched',
    () async {
      final memory = MemoryOrderPersistence();
      final initial = await farmerStore(OrderStore(persistence: memory));
      final order = await place(initial);
      final legacy = jsonDecode(memory.value!) as Map<String, dynamic>;
      legacy['version'] = 2;
      legacy.remove('priceHistory');
      memory.value = jsonEncode(legacy);
      final store = await farmerStore(await OrderStore.restore(memory));
      expect(store.priceHistoryFor('potato-3'), isEmpty);
      expect(store.find(order.id)!.total, 12000);
      await store.saveOffer(
        farmId: 'bereke',
        offerId: 'potato-3',
        draft: draft(productId: 'potatoes', price: 230),
      );
      final data = jsonDecode(memory.value!) as Map<String, dynamic>;
      (data['priceHistory'] as List).first['farmId'] = 'saryarka';
      memory.value = jsonEncode(data);
      final raw = memory.value;
      await expectLater(
        OrderStore.restore(memory),
        throwsA(isA<FormatException>()),
      );
      expect(memory.value, raw);
    },
  );

  testWidgets(
    'farmer completes pickup and buyer sees a completed order after restart',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final memory = MemoryOrderPersistence();
      final store = await farmerStore(OrderStore(persistence: memory));
      final order = await place(store, delivery: false);
      await tester.pumpWidget(FarmDirectApp(orderStore: store));
      await tester.pumpAndSettle();
      await demoLogin(store, 'bereke@farm.demo');
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(Key('farmer-order-${order.id}')));
      for (final action in [
        ('confirm-farmer-order', 'Confirm order'),
        ('ready-farmer-order', 'Mark ready'),
        ('complete-farmer-order', 'Complete order'),
      ]) {
        await tap(tester, find.byKey(Key(action.$1)));
        await tester.tap(find.widgetWithText(FilledButton, action.$2));
        await tester.pumpAndSettle();
      }
      expect(store.find(order.id)!.status, OrderStatus.completed);
      expect(find.byKey(const Key('complete-farmer-order')), findsNothing);
      await tester.pumpWidget(const SizedBox());
      final restored = await farmerStore(await OrderStore.restore(memory));
      await demoLogin(restored);
      await tester.pumpWidget(FarmDirectApp(orderStore: restored));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-orders')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Completed').first);
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(Key('order-${order.id}')));
      await reach(tester, find.byKey(const Key('saved-order-total')));
      expect(
        tester.widget<Text>(find.byKey(const Key('saved-order-total'))).data,
        '₸9 500',
      );
      expect(restored.find(order.id)!.completedAt, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'farmer must give a rejection reason and buyer sees it with restored stock',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = await farmerStore(OrderStore());
      final order = await place(store);
      await tester.pumpWidget(FarmDirectApp(orderStore: store));
      await tester.pumpAndSettle();
      await demoLogin(store, 'bereke@farm.demo');
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(Key('farmer-order-${order.id}')));
      await tap(tester, find.byKey(const Key('reject-farmer-order')));
      await tester.tap(find.widgetWithText(FilledButton, 'Reject order'));
      await tester.pumpAndSettle();
      expect(find.text('Give a reason of 5–300 characters.'), findsOneWidget);
      expect(store.find(order.id)!.status, OrderStatus.pending);
      await tester.enterText(
        find.byKey(const Key('rejection-reason')),
        'Harvest damaged during packing.',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Reject order'));
      await tester.pumpAndSettle();
      expect(store.find(order.id)!.status, OrderStatus.rejected);
      expect(store.availableKg(DemoCatalog.offers[2]), 800);
      await demoLogin(store);
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('open-orders')), delta: -200);
      await tap(tester, find.byKey(Key('order-${order.id}')));
      await reach(tester, find.byKey(const Key('order-rejection-reason')));
      expect(find.text('Harvest damaged during packing.'), findsOneWidget);
      expect(find.byKey(const Key('cancel-order')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'buyer and farmer can inspect price changes on narrow screen with larger text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = await farmerStore(OrderStore());
      await store.saveOffer(
        farmId: 'bereke',
        offerId: 'potato-3',
        draft: draft(productId: 'potatoes', price: 240, fee: 700),
      );
      await store.saveOffer(
        farmId: 'bereke',
        offerId: 'potato-3',
        draft: draft(productId: 'potatoes', price: 220, fee: 0),
      );
      await demoLogin(store);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 720),
              textScaler: TextScaler.linear(1.5),
            ),
            child: FarmDirectApp(orderStore: store),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await openPotatoes(tester);
      await tap(tester, find.byKey(const Key('price-history-potato-3')));
      await reach(tester, find.text('₸240 → ₸220 / kg'));
      expect(find.text('Decrease: ₸20 / kg'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await demoLogin(store, 'bereke@farm.demo');
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('manage-farmer-products')));
      await tap(tester, find.byKey(const Key('farmer-price-history-potato-3')));
      await reach(tester, find.byKey(const Key('history-current-price')));
      expect(
        tester
            .widget<Text>(find.byKey(const Key('history-current-price')))
            .data,
        '₸220 / kg',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
