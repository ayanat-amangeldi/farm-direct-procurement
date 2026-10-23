import 'dart:convert';
import 'package:farm_direct/auth/account.dart';
import 'package:farm_direct/catalog/demo_catalog.dart';
import 'package:farm_direct/main.dart';
import 'package:farm_direct/orders/order.dart';
import 'package:farm_direct/orders/order_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'auth_helpers.dart';
import 'order_store_test.dart'
    show place, FailingPersistence, DelayedPersistence;
import 'offer_management_test.dart' show draft, tap, reach;

const reason = 'Listing details need verification.';

void main() {
  test(
    'only admin can moderate; administrator accounts and unknown targets are protected',
    () async {
      final store = OrderStore();
      for (final email in [null, 'buyer@farm.demo', 'bereke@farm.demo']) {
        if (email != null) await demoLogin(store, email);
        await expectLater(
          store.setAccountBlocked('demo-buyer', blocked: true, reason: reason),
          throwsA(isA<OrderException>()),
        );
        await expectLater(
          store.setOfferHidden('potato-3', hidden: true, reason: reason),
          throwsA(isA<OrderException>()),
        );
        expect(store.moderationHistory, isEmpty);
      }
      await demoLogin(store, 'admin@farm.demo');
      for (final id in ['demo-admin', 'missing']) {
        await expectLater(
          store.setAccountBlocked(id, blocked: true, reason: reason),
          throwsA(isA<OrderException>()),
        );
      }
      await expectLater(
        store.setOfferHidden('missing', hidden: true, reason: reason),
        throwsA(isA<OrderException>()),
      );
      for (final bad in ['', ' bad ', 'x' * 301]) {
        await expectLater(
          store.setAccountBlocked('demo-buyer', blocked: true, reason: bad),
          throwsA(isA<OrderException>()),
        );
        await expectLater(
          store.setOfferHidden('potato-3', hidden: true, reason: bad),
          throwsA(isA<OrderException>()),
        );
      }
      expect(store.moderationHistory, isEmpty);
      expect(store.isAccountBlocked('demo-admin'), isFalse);
    },
  );

  test(
    'blocking and unblocking buyer preserves order terms and survives restoration',
    () async {
      final memory = MemoryOrderPersistence();
      final at = DateTime.utc(2026, 10, 23, 10);
      final store = OrderStore(persistence: memory, now: () => at);
      final order = await place(store);
      await demoLogin(store, 'admin@farm.demo');
      await store.setAccountBlocked(
        'demo-buyer',
        blocked: true,
        reason: '  Account verification required.  ',
      );
      expect(store.moderationHistory.single.at, at);
      expect(store.moderationHistory.single.adminId, 'demo-admin');
      expect(
        store.accountRestriction('demo-buyer')?.reason,
        'Account verification required.',
      );
      expect(store.find(order.id)!.toJson(), order.toJson());
      expect(store.availableKg(DemoCatalog.offers[2]), 750);
      store.signOut();
      await expectLater(
        store.signIn('buyer@farm.demo', demoPassword),
        throwsA(
          isA<OrderException>().having(
            (e) => e.message,
            'blocked message',
            contains('blocked'),
          ),
        ),
      );
      expect(store.currentUser, isNull);
      await expectLater(
        store.register(
          name: 'Other Buyer',
          email: 'BUYER@farm.demo',
          password: demoPassword,
          role: AccountRole.buyer,
        ),
        throwsA(isA<OrderException>()),
      );
      final restored = await OrderStore.restore(memory);
      await demoLogin(restored, 'bereke@farm.demo');
      await restored.confirm(order.id, farmId: 'bereke');
      expect(restored.find(order.id)?.status, OrderStatus.confirmed);
      await demoLogin(restored, 'admin@farm.demo');
      await restored.setAccountBlocked(
        'demo-buyer',
        blocked: false,
        reason: 'Account verification completed.',
      );
      expect(restored.moderationHistory, hasLength(2));
      await demoLogin(restored);
      expect(restored.find(order.id)?.total, 12000);
      expect(restored.find(order.id)?.status, OrderStatus.confirmed);
    },
  );

  test(
    'hidden offer rejects cached checkout; farmer edits cannot restore visibility',
    () async {
      final memory = MemoryOrderPersistence();
      final store = await farmerStore(OrderStore(persistence: memory));
      final custom = await store.saveOffer(farmId: 'bereke', draft: draft());
      final product = store.product(custom.productId)!;
      final order = await place(store);
      final before = store.find(order.id)!.toJson();
      await demoLogin(store, 'admin@farm.demo');
      await store.setOfferHidden(custom.id, hidden: true, reason: reason);
      expect(
        store.catalogProducts.any((p) => p.id == custom.productId),
        isFalse,
      );
      expect(store.offersFor(custom.productId), isEmpty);
      expect(store.offer(custom.id), isNotNull);
      await demoLogin(store);
      await expectLater(
        store.place(
          product: product,
          offer: custom,
          kg: 10,
          delivery: false,
          contactName: 'Demo Buyer',
          phone: '+7 700 000 00 00',
          address: '',
          note: '',
        ),
        throwsA(isA<OrderException>()),
      );
      expect(store.orders.single.toJson(), before);
      await demoLogin(store, 'bereke@farm.demo');
      await store.saveOffer(
        farmId: 'bereke',
        offerId: custom.id,
        draft: draft(productId: custom.productId, price: 250),
      );
      expect(store.isOfferHidden(custom.id), isTrue);
      expect(store.priceHistoryFor(custom.id), hasLength(2));
      expect(store.farmOffers('bereke').any((o) => o.id == custom.id), isTrue);
      final restored = await OrderStore.restore(memory);
      await demoLogin(restored, 'admin@farm.demo');
      expect(restored.isOfferHidden(custom.id), isTrue);
      await restored.setOfferHidden(
        custom.id,
        hidden: false,
        reason: 'Listing details verified.',
      );
      await demoLogin(restored);
      expect(
        restored.catalogProducts.any((p) => p.id == custom.productId),
        isTrue,
      );
      expect(restored.offersFor(custom.productId).single.pricePerKg, 250);
      expect(restored.find(order.id)!.toJson(), before);
    },
  );

  test(
    'farmer block removes all their offers but unblock keeps explicitly hidden ones hidden',
    () async {
      final store = OrderStore();
      final order = await place(store);
      await demoLogin(store, 'admin@farm.demo');
      await store.setOfferHidden('potato-3', hidden: true, reason: reason);
      await store.setAccountBlocked(
        'demo-bereke',
        blocked: true,
        reason: 'Farm identity needs verification.',
      );
      expect(store.offersFor('potatoes').map((o) => o.id), [
        'potato-1',
        'potato-2',
      ]);
      expect(store.offersFor('carrots').map((o) => o.id), ['carrot-1']);
      expect(store.offers, hasLength(12));
      expect(store.find(order.id)?.total, 12000);
      await expectLater(
        store.signIn('bereke@farm.demo', demoPassword),
        throwsA(isA<OrderException>()),
      );
      await demoLogin(store);
      await expectLater(place(store), throwsA(isA<OrderException>()));
      await demoLogin(store, 'admin@farm.demo');
      await store.setAccountBlocked(
        'demo-bereke',
        blocked: false,
        reason: 'Farm identity verified.',
      );
      expect(store.offersFor('carrots'), hasLength(2));
      expect(store.offersFor('potatoes'), hasLength(2));
      await demoLogin(store, 'bereke@farm.demo');
      await store.confirm(order.id, farmId: 'bereke');
      expect(store.find(order.id)?.status, OrderStatus.confirmed);
      await demoLogin(store, 'admin@farm.demo');
      await store.setOfferHidden(
        'potato-3',
        hidden: false,
        reason: 'Product details now verified.',
      );
      expect(store.offersFor('potatoes'), hasLength(3));
      expect(store.moderationHistory, hasLength(4));
    },
  );

  test('restoring an offer never overrides a blocked farmer', () async {
    final store = await buyerStore(OrderStore());
    await demoLogin(store, 'admin@farm.demo');
    await store.setOfferHidden('potato-3', hidden: true, reason: reason);
    await store.setAccountBlocked('demo-bereke', blocked: true, reason: reason);
    await store.setOfferHidden(
      'potato-3',
      hidden: false,
      reason: 'Offer description verified.',
    );
    expect(store.isOfferHidden('potato-3'), isFalse);
    expect(store.isOfferVisible(store.offer('potato-3')!), isFalse);
    await demoLogin(store);
    await expectLater(place(store), throwsA(isA<OrderException>()));
  });

  test(
    'save failure leaves restrictions, history, orders and stored bytes unchanged',
    () async {
      final memory = MemoryOrderPersistence();
      final initial = OrderStore(persistence: memory);
      final order = await place(initial);
      final failing = FailingPersistence()..value = memory.value;
      final store = await OrderStore.restore(failing);
      await demoLogin(store, 'admin@farm.demo');
      for (final action in [
        () => store.setAccountBlocked(
          'demo-buyer',
          blocked: true,
          reason: reason,
        ),
        () => store.setOfferHidden('potato-3', hidden: true, reason: reason),
      ]) {
        await expectLater(action(), throwsA(isA<OrderException>()));
        expect(store.moderationHistory, isEmpty);
        expect(store.isAccountBlocked('demo-buyer'), isFalse);
        expect(store.isOfferHidden('potato-3'), isFalse);
        expect(store.find(order.id)!.toJson(), order.toJson());
        expect(failing.value, memory.value);
      }
      await demoLogin(initial, 'admin@farm.demo');
      await initial.setAccountBlocked(
        'demo-buyer',
        blocked: true,
        reason: reason,
      );
      await initial.setOfferHidden('potato-3', hidden: true, reason: reason);
      final undoFailure = FailingPersistence()..value = memory.value;
      final undo = await OrderStore.restore(undoFailure);
      await demoLogin(undo, 'admin@farm.demo');
      await expectLater(
        undo.setAccountBlocked('demo-buyer', blocked: false, reason: reason),
        throwsA(isA<OrderException>()),
      );
      await expectLater(
        undo.setOfferHidden('potato-3', hidden: false, reason: reason),
        throwsA(isA<OrderException>()),
      );
      expect(undo.isAccountBlocked('demo-buyer'), isTrue);
      expect(undo.isOfferHidden('potato-3'), isTrue);
      expect(undo.moderationHistory, hasLength(2));
      expect(undoFailure.value, memory.value);
    },
  );

  test(
    'concurrent actions cannot lose a moderation record or change the actor',
    () async {
      final delayed = DelayedPersistence();
      final store = OrderStore(persistence: delayed);
      await demoLogin(store, 'admin@farm.demo');
      final hiding = store.setOfferHidden(
        'potato-3',
        hidden: true,
        reason: reason,
      );
      await expectLater(
        store.setAccountBlocked('demo-buyer', blocked: true, reason: reason),
        throwsA(isA<OrderException>()),
      );
      expect(store.signOut, throwsA(isA<OrderException>()));
      await expectLater(
        store.signIn('buyer@farm.demo', demoPassword),
        throwsA(isA<OrderException>()),
      );
      expect(store.isOfferHidden('potato-3'), isFalse);
      delayed.gate.complete();
      await hiding;
      expect(store.moderationHistory, hasLength(1));
      await expectLater(
        store.setOfferHidden('potato-3', hidden: true, reason: reason),
        throwsA(isA<OrderException>()),
      );
      expect(store.moderationHistory, hasLength(1));
    },
  );

  test(
    'v4 data acquires an empty history; malformed moderation is never overwritten',
    () async {
      final memory = MemoryOrderPersistence();
      final order = await place(OrderStore(persistence: memory));
      final legacy = jsonDecode(memory.value!) as Map<String, dynamic>;
      legacy['version'] = 4;
      legacy.remove('moderation');
      memory.value = jsonEncode(legacy);
      final store = await OrderStore.restore(memory);
      await demoLogin(store, 'admin@farm.demo');
      expect(store.moderationHistory, isEmpty);
      expect(store.find(order.id)?.total, 12000);
      await store.setOfferHidden('potato-3', hidden: true, reason: reason);
      final saved = jsonDecode(memory.value!) as Map<String, dynamic>;
      expect(saved['version'], 5);
      for (final patch in [
        {'targetId': 'missing'},
        {'adminId': 'demo-buyer'},
        {'reason': 'bad'},
        {'target': 'account', 'targetId': 'demo-admin'},
      ]) {
        final bad = jsonDecode(jsonEncode(saved)) as Map<String, dynamic>;
        (bad['moderation'] as List).single.addAll(patch);
        memory.value = jsonEncode(bad);
        final raw = memory.value;
        await expectLater(
          OrderStore.restore(memory),
          throwsA(isA<FormatException>()),
        );
        expect(memory.value, raw);
      }
    },
  );

  testWidgets(
    'admin validates reason, blocks buyer, hides an offer and restores it at narrow width',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = OrderStore();
      final order = await place(store);
      await demoLogin(store, 'admin@farm.demo');
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: FarmDirectApp(orderStore: store),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('moderate-account-demo-admin')),
        findsNothing,
      );
      await tap(tester, find.byKey(const Key('moderate-account-demo-buyer')));
      await tap(tester, find.byKey(const Key('confirm-moderation')));
      expect(find.text('Give a reason of 5–300 characters.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('moderation-reason')),
        'Account verification required.',
      );
      await tester.tap(find.byKey(const Key('confirm-moderation')));
      await tester.pumpAndSettle();
      expect(store.isAccountBlocked('demo-buyer'), isTrue);
      await tap(tester, find.byKey(const Key('admin-offers')), delta: -200);
      await reach(tester, find.byKey(const ValueKey('admin-search-1')));
      await tester.enterText(
        find.byKey(const ValueKey('admin-search-1')),
        'potatoes bereke',
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('moderate-offer-potato-3')));
      await tester.enterText(
        find.byKey(const Key('moderation-reason')),
        reason,
      );
      await tester.tap(find.byKey(const Key('confirm-moderation')));
      await tester.pumpAndSettle();
      expect(store.isOfferHidden('potato-3'), isTrue);
      await tap(tester, find.byKey(const Key('moderate-offer-potato-3')));
      await tester.enterText(
        find.byKey(const Key('moderation-reason')),
        'Listing details verified.',
      );
      await tester.tap(find.byKey(const Key('confirm-moderation')));
      await tester.pumpAndSettle();
      expect(store.isOfferHidden('potato-3'), isFalse);
      expect(store.find(order.id)?.total, 12000);
      await tap(tester, find.byKey(const Key('admin-history')), delta: -200);
      await reach(tester, find.text('Offer restored'));
      expect(find.text('Listing details verified.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'buyer comparison excludes hidden offers; farmer sees reason without restore control',
    (tester) async {
      final store = OrderStore();
      await demoLogin(store, 'admin@farm.demo');
      await store.setOfferHidden('potato-3', hidden: true, reason: reason);
      await demoLogin(store);
      await tester.pumpWidget(FarmDirectApp(orderStore: store));
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('product-potatoes')));
      expect(find.byKey(const Key('view-potato-3')), findsNothing);
      expect(find.text('2 offers available'), findsOneWidget);
      await demoLogin(store, 'bereke@farm.demo');
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('manage-farmer-products')));
      await reach(tester, find.byKey(const Key('offer-moderation-potato-3')));
      expect(find.text('Hidden by administrator: $reason'), findsOneWidget);
      expect(find.text('Restore offer'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
