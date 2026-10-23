import 'auth_helpers.dart';
import 'dart:convert';
import 'package:farm_direct/catalog/models.dart';
import 'package:farm_direct/catalog/offer_draft.dart';
import 'package:farm_direct/main.dart';
import 'package:farm_direct/orders/order_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'order_store_test.dart'
    show place, FailingPersistence, DelayedPersistence;

OfferDraft draft({
  String? productId,
  String name = 'Onions',
  int price = 220,
  int stock = 100,
  int minimum = 10,
  int? fee = 700,
}) => OfferDraft(
  productId: productId,
  newProductName: name,
  newProductCategory: ProductCategory.vegetables,
  newProductDescription: 'For everyday cooking',
  pricePerKg: price,
  totalStockKg: stock,
  minimumKg: minimum,
  deliveryFee: fee,
  location: 'Karaganda region',
  description: 'Brown onions, packed in 10 kg bags',
);

Future<void> reach(
  WidgetTester tester,
  Finder finder, {
  double delta = 200,
}) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: find.byType(Scrollable).first,
    );
  } else {
    await tester.ensureVisible(finder);
  }
  await tester.pumpAndSettle();
}

Future<void> tap(
  WidgetTester tester,
  Finder finder, {
  double delta = 200,
}) async {
  await reach(tester, finder, delta: delta);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  test(
    'new product and farm offer persist together and can be ordered',
    () async {
      final persistence = MemoryOrderPersistence();
      final store = await farmerStore(OrderStore(persistence: persistence));
      final offer = await store.saveOffer(farmId: 'bereke', draft: draft());
      final product = store.product(offer.productId)!;
      expect(product.name, 'Onions');
      expect(store.products, hasLength(7));
      expect(store.offersFor(product.id).single.id, offer.id);
      await demoLogin(store);
      final order = await store.place(
        product: product,
        offer: offer,
        kg: 10,
        delivery: true,
        contactName: 'Demo Buyer',
        phone: '+7 700 000 00 00',
        address: 'Demo Street 1',
        note: '',
      );
      expect(order.total, 2900);
      final restored = await farmerStore(await OrderStore.restore(persistence));
      expect(restored.product(product.id)!.toJson(), product.toJson());
      expect(restored.offer(offer.id)!.toJson(), offer.toJson());
      expect(restored.availableKg(restored.offer(offer.id)!), 90);
      expect(restored.find(order.id)!.total, 2900);
      await demoLogin(restored, 'bereke@farm.demo');
      final next = await restored.saveOffer(
        farmId: 'bereke',
        draft: draft(name: 'Pumpkins'),
      );
      expect(next.id, isNot(offer.id));
      expect(next.productId, isNot(offer.productId));
    },
  );

  test(
    'existing types join the same catalog group; duplicate farm offers are rejected',
    () async {
      final store = await farmerStore(OrderStore());
      final offer = await store.saveOffer(
        farmId: 'bereke',
        draft: draft(productId: 'tomatoes', price: 410),
      );
      expect(store.products, hasLength(6));
      expect(store.offersFor('tomatoes'), hasLength(3));
      expect(offer.productId, 'tomatoes');
      await expectLater(
        store.saveOffer(
          farmId: 'bereke',
          draft: draft(productId: 'tomatoes'),
        ),
        throwsA(isA<OrderException>()),
      );
      await expectLater(
        store.saveOffer(
          farmId: 'bereke',
          draft: draft(name: '  TOMATOES  '),
        ),
        throwsA(isA<OrderException>()),
      );
      expect(store.products, hasLength(6));
      expect(store.offersFor('tomatoes'), hasLength(3));
    },
  );

  test(
    'editing changes future quotes but preserves ordered terms and committed stock',
    () async {
      final store = await farmerStore(OrderStore());
      final order = await place(store);
      final before = store.find(order.id)!.toJson();
      final old = store.offer('potato-3')!;
      final updated = await store.saveOffer(
        farmId: 'bereke',
        offerId: old.id,
        draft: draft(
          productId: 'potatoes',
          price: 250,
          stock: 100,
          minimum: 20,
          fee: 900,
        ),
      );
      expect(store.availableKg(updated), 50);
      expect(updated.quote(kg: 20, delivery: true).total, 5900);
      expect(store.find(order.id)!.toJson(), before);
      await expectLater(
        place(store, selectedOffer: old),
        throwsA(isA<OrderException>()),
      );
      final second = await place(store, selectedOffer: updated, kg: 20);
      expect(second.total, 5900);
      expect(store.availableKg(updated), 30);
      await expectLater(
        store.saveOffer(
          farmId: 'bereke',
          offerId: old.id,
          draft: draft(productId: 'potatoes', stock: 60, minimum: 20),
        ),
        throwsA(isA<OrderException>()),
      );
      expect(store.offer(old.id)!.availableKg, 100);
      await demoLogin(store);
      await store.cancel(order.id);
      expect(store.availableKg(updated), 80);
    },
  );

  test(
    'invalid drafts, another farm and changed product identity cannot mutate catalog',
    () async {
      final store = await farmerStore(OrderStore());
      for (final invalid in [
        draft(price: 0),
        draft(stock: -1),
        draft(stock: 5),
        draft(minimum: 0),
        draft(fee: -1),
        draft(name: ' '),
        draft(productId: 'missing'),
      ]) {
        await expectLater(
          store.saveOffer(farmId: 'bereke', draft: invalid),
          throwsA(isA<OrderException>()),
        );
      }
      await expectLater(
        store.saveOffer(
          farmId: 'saryarka',
          offerId: 'potato-3',
          draft: draft(productId: 'potatoes'),
        ),
        throwsA(isA<OrderException>()),
      );
      await expectLater(
        store.saveOffer(
          farmId: 'bereke',
          offerId: 'potato-3',
          draft: draft(productId: 'tomatoes'),
        ),
        throwsA(isA<OrderException>()),
      );
      await expectLater(
        store.saveOffer(farmId: 'unknown', draft: draft()),
        throwsA(isA<OrderException>()),
      );
      expect(store.products, hasLength(6));
      expect(store.offers, hasLength(12));
      final paused = await store.saveOffer(
        farmId: 'bereke',
        offerId: 'potato-3',
        draft: draft(productId: 'potatoes', stock: 0),
      );
      expect(store.availableKg(paused), 0);
    },
  );

  test(
    'failed publication creates neither a product nor an offer and keeps stored history',
    () async {
      final memory = MemoryOrderPersistence();
      final order = await place(
        await farmerStore(OrderStore(persistence: memory)),
      );
      final failing = FailingPersistence()..value = memory.value;
      final store = await farmerStore(await OrderStore.restore(failing));
      await expectLater(
        store.saveOffer(farmId: 'bereke', draft: draft()),
        throwsA(isA<OrderException>()),
      );
      expect(store.products, hasLength(6));
      expect(store.offers, hasLength(12));
      expect(store.find(order.id), isNotNull);
      expect(failing.value, memory.value);
    },
  );

  test('catalog updates and checkout share a write lock', () async {
    final persistence = DelayedPersistence();
    final store = await farmerStore(OrderStore(persistence: persistence));
    final saving = store.saveOffer(
      farmId: 'bereke',
      offerId: 'potato-3',
      draft: draft(productId: 'potatoes'),
    );
    await expectLater(place(store), throwsA(isA<OrderException>()));
    persistence.gate.complete();
    await saving;
    expect(store.orders, isEmpty);
    expect(store.offer('potato-3')!.pricePerKg, 220);
  });

  test(
    'version-one history migrates without losing orders; invalid catalogs stay untouched',
    () async {
      final memory = MemoryOrderPersistence();
      final order = await place(await farmerStore(OrderStore()));
      memory.value = jsonEncode({
        'version': 1,
        'orders': [order.toJson()],
      });
      final migrated = await farmerStore(await OrderStore.restore(memory));
      expect(migrated.products, hasLength(6));
      await migrated.saveOffer(farmId: 'bereke', draft: draft());
      final restored = await farmerStore(await OrderStore.restore(memory));
      expect(restored.products, hasLength(7));
      expect(restored.find(order.id)!.total, order.total);
      final malformed = jsonDecode(memory.value!) as Map<String, dynamic>;
      (malformed['offers'] as List).first['productId'] = 'missing-product';
      memory.value = jsonEncode(malformed);
      final original = memory.value;
      await expectLater(
        OrderStore.restore(memory),
        throwsA(isA<FormatException>()),
      );
      expect(memory.value, original);
    },
  );

  testWidgets(
    'farmer publishes and edits a product and buyer gets updated catalog and quote',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final memory = MemoryOrderPersistence();
      final store = await farmerStore(OrderStore(persistence: memory));
      final oldOrder = await place(store);
      await tester.pumpWidget(FarmDirectApp(orderStore: store));
      await tester.pumpAndSettle();
      await demoLogin(store, 'bereke@farm.demo');
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('manage-farmer-products')));
      await tap(tester, find.byKey(const Key('add-farmer-product')));
      await tap(tester, find.byKey(const Key('save-farmer-offer')));
      expect(
        find.text('Enter a product name of at least 2 characters.'),
        findsOneWidget,
      );
      expect(store.products, hasLength(6));
      for (final entry in {
        'new-product-name': 'Onions',
        'offer-price': '220',
        'offer-stock': '100',
        'offer-minimum': '10',
        'offer-description': 'Brown onions in 10 kg bags',
      }.entries) {
        final field = find.byKey(Key(entry.key));
        await reach(tester, field);
        await tester.enterText(field, entry.value);
        await tester.pumpAndSettle();
      }
      await tap(tester, find.byKey(const Key('offer-delivery')));
      await reach(tester, find.byKey(const Key('offer-delivery-fee')));
      await tester.enterText(
        find.byKey(const Key('offer-delivery-fee')),
        '700',
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('save-farmer-offer')));
      final offer = store.offers.singleWhere(
        (item) => item.id.startsWith('custom-offer'),
      );
      await tap(tester, find.byKey(Key('edit-offer-${offer.id}')));
      await reach(tester, find.byKey(const Key('offer-price')));
      await tester.enterText(find.byKey(const Key('offer-price')), '240');
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('save-farmer-offer')));
      expect(store.offer(offer.id)!.pricePerKg, 240);
      expect(store.find(oldOrder.id)!.total, 12000);
      await demoLogin(store);
      await tester.pumpAndSettle();
      await reach(tester, find.byKey(const Key('catalog-search')), delta: -200);
      await tester.enterText(find.byKey(const Key('catalog-search')), 'onions');
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(Key('product-${offer.productId}')));
      await tap(tester, find.byKey(Key('view-${offer.id}')));
      expect(
        tester.widget<Text>(find.byKey(const Key('quote-total'))).data,
        '₸2 400',
      );
      await tap(tester, find.text('Delivery · ₸700'));
      expect(
        tester.widget<Text>(find.byKey(const Key('quote-total'))).data,
        '₸3 100',
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      final restored = await farmerStore(await OrderStore.restore(memory));
      await demoLogin(restored);
      await tester.pumpWidget(FarmDirectApp(orderStore: restored));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('catalog-search')), 'onions');
      await tester.pumpAndSettle();
      await reach(tester, find.byKey(Key('product-${offer.productId}')));
      expect(restored.offer(offer.id)!.pricePerKg, 240);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('publication form works on a narrow screen with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = await farmerStore(OrderStore());
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
    await demoLogin(store, 'bereke@farm.demo');
    await tester.pumpAndSettle();
    await tap(tester, find.byKey(const Key('manage-farmer-products')));
    await tap(tester, find.byKey(const Key('add-farmer-product')));
    for (final entry in {
      'new-product-name': 'Onions',
      'offer-price': '220',
      'offer-stock': '100',
      'offer-minimum': '10',
    }.entries) {
      final field = find.byKey(Key(entry.key));
      await reach(tester, field);
      await tester.enterText(field, entry.value);
      await tester.pumpAndSettle();
    }
    expect(
      MediaQuery.textScalerOf(
        tester.element(find.byKey(const Key('offer-price'))),
      ).scale(14),
      21,
    );
    await tap(tester, find.byKey(const Key('save-farmer-offer')));
    expect(store.products.last.name, 'Onions');
    expect(tester.takeException(), isNull);
  });
}
