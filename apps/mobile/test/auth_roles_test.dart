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

void main() {
  test(
    'all demo roles authenticate; invalid credentials preserve session',
    () async {
      final store = OrderStore();
      expect(store.currentUser, isNull);
      expect(store.orders, isEmpty);
      for (final account in demoAccounts) {
        await store.signIn('  ${account.email.toUpperCase()}  ', demoPassword);
        expect(store.currentUser?.id, account.id);
      }
      for (final email in ['buyer@farm.demo', 'unknown@farm.demo']) {
        await expectLater(
          store.signIn(email, 'wrong password'),
          throwsA(isA<OrderException>()),
        );
        expect(store.currentUser?.id, demoAccounts.last.id);
      }
      store.signOut();
      expect(store.currentUser, isNull);
    },
  );

  test(
    'registration hashes passwords, normalizes emails and restores accounts signed out',
    () async {
      final memory = MemoryOrderPersistence();
      final store = OrderStore(persistence: memory);
      await store.register(
        name: ' Sample Buyer ',
        email: ' New@Farm.demo ',
        password: 'SamplePassword123!',
        role: AccountRole.buyer,
      );
      final id = store.currentUser!.id;
      expect(store.currentUser?.name, 'Sample Buyer');
      expect(store.currentUser?.email, 'new@farm.demo');
      expect(memory.value, isNot(contains('SamplePassword123!')));
      expect(memory.value, isNot(contains('FarmDemo2026!')));
      expect(jsonDecode(memory.value!)['version'], 5);
      final order = await store.place(
        product: DemoCatalog.products.first,
        offer: DemoCatalog.offers[2],
        kg: 50,
        delivery: false,
        contactName: 'Sample Buyer',
        phone: '+7 700 000 00 00',
        address: '',
        note: '',
      );
      expect(order.buyerId, id);
      final restored = await OrderStore.restore(memory);
      expect(restored.currentUser, isNull);
      expect(restored.find(order.id), isNull);
      await restored.signIn('new@farm.demo', 'SamplePassword123!');
      expect(restored.find(order.id)?.buyerId, id);
      expect(restored.orders.single.total, 9500);
      restored.signOut();
      await expectLater(
        restored.register(
          name: 'Other Buyer',
          email: 'NEW@farm.demo',
          password: 'SamplePassword123!',
          role: AccountRole.buyer,
        ),
        throwsA(isA<OrderException>()),
      );
      await demoLogin(restored);
      expect(restored.orders, isEmpty);
      expect(restored.find(order.id), isNull);
      await expectLater(
        restored.cancel(order.id),
        throwsA(isA<OrderException>()),
      );
    },
  );

  test(
    'farm registration creates independent ownership and a visible catalog offer',
    () async {
      final memory = MemoryOrderPersistence();
      final store = OrderStore(persistence: memory);
      await store.register(
        name: 'Sample Farmer',
        email: 'newfarm@farm.demo',
        password: 'SamplePassword123!',
        role: AccountRole.farmer,
        farmName: 'Sample Orchard',
        region: 'Almaty region',
      );
      final farmId = store.currentUser!.farmId!;
      expect(farmId, isNot('bereke'));
      expect(store.currentFarm?.name, 'Sample Orchard');
      expect(store.farmOffers(farmId), isEmpty);
      await expectLater(
        store.saveOffer(farmId: 'bereke', draft: draft()),
        throwsA(isA<OrderException>()),
      );
      final published = await store.saveOffer(farmId: farmId, draft: draft());
      expect(published.farmName, 'Sample Orchard');
      await demoLogin(store);
      final order = await store.place(
        product: store.product(published.productId)!,
        offer: published,
        kg: 10,
        delivery: false,
        contactName: 'Demo Buyer',
        phone: '+7 700 000 00 00',
        address: '',
        note: '',
      );
      await demoLogin(store, 'bereke@farm.demo');
      expect(store.find(order.id), isNull);
      await expectLater(
        store.confirm(order.id, farmId: farmId),
        throwsA(isA<OrderException>()),
      );
      final restored = await OrderStore.restore(memory);
      await restored.signIn('newfarm@farm.demo', 'SamplePassword123!');
      expect(restored.currentFarm?.id, farmId);
      await restored.confirm(order.id, farmId: farmId);
      expect(restored.find(order.id)?.status, OrderStatus.confirmed);
    },
  );

  test(
    'unauthenticated, buyer and admin cannot perform farmer operations',
    () async {
      final store = OrderStore();
      await expectLater(
        store.place(
          product: DemoCatalog.products.first,
          offer: DemoCatalog.offers[2],
          kg: 50,
          delivery: false,
          contactName: 'Demo Buyer',
          phone: '+7 700 000 00 00',
          address: '',
          note: '',
        ),
        throwsA(isA<OrderException>()),
      );
      final order = await place(store);
      await expectLater(
        store.saveOffer(farmId: 'bereke', draft: draft()),
        throwsA(isA<OrderException>()),
      );
      await expectLater(
        store.confirm(order.id, farmId: 'bereke'),
        throwsA(isA<OrderException>()),
      );
      expect(store.accounts, isEmpty);
      await demoLogin(store, 'admin@farm.demo');
      expect(store.accounts, hasLength(7));
      expect(store.orders.single.id, order.id);
      await expectLater(store.cancel(order.id), throwsA(isA<OrderException>()));
      await expectLater(
        store.confirm(order.id, farmId: 'bereke'),
        throwsA(isA<OrderException>()),
      );
      await expectLater(
        store.saveOffer(farmId: 'bereke', draft: draft()),
        throwsA(isA<OrderException>()),
      );
      store.signOut();
      expect(store.find(order.id), isNull);
      await expectLater(
        store.register(
          name: 'New Admin',
          email: 'owner@farm.demo',
          password: demoPassword,
          role: AccountRole.admin,
        ),
        throwsA(isA<OrderException>()),
      );
    },
  );

  test(
    'invalid or failed registration publishes no account, farm or session',
    () async {
      for (final values in [
        ('A', 'new@farm.demo', demoPassword),
        ('New Buyer', 'bad email', demoPassword),
        ('New Buyer', 'new@farm.demo', 'short'),
      ]) {
        final store = OrderStore();
        await expectLater(
          store.register(
            name: values.$1,
            email: values.$2,
            password: values.$3,
            role: AccountRole.buyer,
          ),
          throwsA(isA<OrderException>()),
        );
        expect(store.currentUser, isNull);
      }
      final memory = FailingPersistence();
      final store = OrderStore(persistence: memory);
      await expectLater(
        store.register(
          name: 'Sample Farmer',
          email: 'new@farm.demo',
          password: demoPassword,
          role: AccountRole.farmer,
          farmName: 'Sample Farm',
          region: 'Akmola region',
        ),
        throwsA(isA<OrderException>()),
      );
      expect(store.currentUser, isNull);
      expect(store.currentFarm, isNull);
      expect(memory.value, isNull);
      await expectLater(
        store.signIn('new@farm.demo', demoPassword),
        throwsA(isA<OrderException>()),
      );
      await demoLogin(store, 'admin@farm.demo');
      expect(store.accounts, hasLength(7));
    },
  );

  test(
    'sessions cannot switch during a pending write; duplicate registration is atomic',
    () async {
      final delayed = DelayedPersistence();
      final store = OrderStore(persistence: delayed);
      final registering = store.register(
        name: 'Sample Farmer',
        email: 'new@farm.demo',
        password: demoPassword,
        role: AccountRole.farmer,
        farmName: 'Sample Farm',
        region: 'Akmola region',
      );
      await expectLater(
        store.register(
          name: 'Other Buyer',
          email: 'new@farm.demo',
          password: demoPassword,
          role: AccountRole.buyer,
        ),
        throwsA(isA<OrderException>()),
      );
      expect(store.signOut, throwsA(isA<OrderException>()));
      await expectLater(
        store.signIn('admin@farm.demo', demoPassword),
        throwsA(isA<OrderException>()),
      );
      delayed.gate.complete();
      await registering;
      expect(store.currentUser?.email, 'new@farm.demo');
      store.signOut();
      await demoLogin(store, 'admin@farm.demo');
      expect(
        store.accounts.where((a) => a.email == 'new@farm.demo'),
        hasLength(1),
      );
    },
  );

  test(
    'legacy orders belong to demo buyer, never to a newly registered buyer',
    () async {
      final memory = MemoryOrderPersistence();
      final order = await place(OrderStore());
      final legacy = order.toJson()..remove('buyerId');
      memory.value = jsonEncode({
        'version': 1,
        'orders': [legacy],
      });
      final store = await OrderStore.restore(memory);
      await store.register(
        name: 'New Buyer',
        email: 'new@farm.demo',
        password: demoPassword,
        role: AccountRole.buyer,
      );
      expect(store.orders, isEmpty);
      await demoLogin(store);
      expect(store.find(order.id)?.buyerId, 'demo-buyer');
      final data = jsonDecode(memory.value!);
      (data['orders'] as List).single.remove('buyerId');
      memory.value = jsonEncode(data);
      await expectLater(
        OrderStore.restore(memory),
        throwsA(isA<FormatException>()),
      );
    },
  );

  testWidgets(
    'login validates, reports bad credentials, clears navigation on logout and routes admin',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = OrderStore();
      await tester.pumpWidget(FarmDirectApp(orderStore: store));
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('auth-submit')));
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('auth-email')),
        'buyer@farm.demo',
      );
      await tester.enterText(
        find.byKey(const Key('auth-password')),
        'bad password',
      );
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('auth-submit')));
        await Future<void>.delayed(const Duration(milliseconds: 700));
      });
      await tester.pumpAndSettle();
      expect(find.text('Email or password is incorrect.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('auth-password')),
        demoPassword,
      );
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('auth-submit')));
        await Future<void>.delayed(const Duration(milliseconds: 700));
      });
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('open-orders')), delta: -200);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('sign-out')), delta: -200);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(
        tester
            .element(find.byType(Scaffold))
            .findAncestorStateOfType<NavigatorState>()!
            .canPop(),
        isFalse,
      );
      await demoLogin(store, 'admin@farm.demo');
      await tester.pumpAndSettle();
      expect(find.text('Marketplace overview'), findsOneWidget);
      await tap(tester, find.byKey(const Key('admin-orders')));
      expect(find.text('No orders yet.'), findsOneWidget);
      expect(find.byKey(const Key('open-farmer-workspace')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'registration form confirms password and opens own farmer workspace at narrow width',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = OrderStore();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: FarmDirectApp(orderStore: store),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('auth-toggle')));
      await tap(tester, find.byKey(const Key('register-farmer')));
      for (final entry in {
        'auth-name': 'Sample Farmer',
        'auth-farm': 'Sample Orchard',
        'auth-region': 'Almaty region',
        'auth-email': 'newfarm@farm.demo',
        'auth-password': demoPassword,
        'auth-confirm-password': 'different',
      }.entries) {
        await reach(
          tester,
          find.byKey(Key(entry.key)),
          delta: entry.key == 'auth-name' ? -200 : 200,
        );
        await tester.enterText(find.byKey(Key(entry.key)), entry.value);
      }
      await tap(tester, find.byKey(const Key('auth-submit')));
      expect(find.text('Passwords must match.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('auth-confirm-password')),
        demoPassword,
      );
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('auth-submit')));
        await Future<void>.delayed(const Duration(milliseconds: 700));
      });
      await tester.pumpAndSettle();
      expect(store.currentUser?.role, AccountRole.farmer);
      expect(find.byKey(const Key('farmer-selector')), findsNothing);
      expect(find.text('Sample Orchard'), findsOneWidget);
      await reach(tester, find.text('No orders for this farm yet'));
      expect(tester.takeException(), isNull);
    },
  );
}
