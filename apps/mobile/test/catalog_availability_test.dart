import 'package:farm_direct/catalog/models.dart';
import 'package:farm_direct/catalog/offer_draft.dart';
import 'package:farm_direct/main.dart';
import 'package:farm_direct/orders/order_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'auth_helpers.dart';

OfferDraft availabilityDraft({String? productId, int stock = 20}) => OfferDraft(
  productId: productId,
  newProductName: 'Availability onions',
  newProductCategory: ProductCategory.vegetables,
  pricePerKg: 220,
  totalStockKg: stock,
  minimumKg: 10,
  deliveryFee: null,
  location: 'Demo region',
  description: '',
);

Future<void> orderAvailableStock(
  OrderStore store,
  FarmerOffer offer,
  int kg,
) async {
  await store.place(
    product: store.product(offer.productId)!,
    offer: offer,
    kg: kg,
    delivery: false,
    contactName: 'Demo Buyer',
    phone: '77000000000',
    address: '',
    note: '',
  );
}

void main() {
  test(
    'catalog follows minimum stock, restocking and released commitments without deleting offers',
    () async {
      final store = await farmerStore(OrderStore());
      var offer = await store.saveOffer(
        farmId: 'bereke',
        draft: availabilityDraft(stock: 0),
      );
      bool listed() =>
          store.catalogProducts.any((p) => p.id == offer.productId);
      expect(listed(), isFalse);
      expect(store.product(offer.productId), isNotNull);
      expect(store.farmOffers('bereke').any((o) => o.id == offer.id), isTrue);

      offer = await store.saveOffer(
        farmId: 'bereke',
        offerId: offer.id,
        draft: availabilityDraft(productId: offer.productId, stock: 10),
      );
      expect(listed(), isTrue); // Exactly the minimum is purchasable.
      offer = await store.saveOffer(
        farmId: 'bereke',
        offerId: offer.id,
        draft: availabilityDraft(productId: offer.productId),
      );
      await demoLogin(store);
      await orderAvailableStock(store, offer, 15);
      final first = store.orders.single;
      expect(store.availableKg(offer), 5);
      expect(
        listed(),
        isFalse,
      ); // Positive stock below the minimum is excluded.
      expect(store.find(first.id)?.total, 3300);
      await store.cancel(first.id);
      expect(listed(), isTrue);

      await orderAvailableStock(store, offer, 20);
      final second = store.orders.first;
      expect(store.availableKg(offer), 0);
      expect(listed(), isFalse);
      await demoLogin(store, 'bereke@farm.demo');
      await store.reject(
        second.id,
        farmId: 'bereke',
        reason: 'Requested collection time is unavailable.',
      );
      expect(store.availableKg(offer), 20);
      expect(listed(), isTrue);
      expect(store.offer(offer.id), isNotNull);
      expect(store.find(second.id)?.total, 4400);
    },
  );

  test(
    'another farm keeps a product listed only while its sufficient-stock offer is visible and active',
    () async {
      final store = await farmerStore(OrderStore());
      final empty = await store.saveOffer(
        farmId: 'bereke',
        draft: availabilityDraft(stock: 0),
      );
      await demoLogin(store, 'saryarka@farm.demo');
      final available = await store.saveOffer(
        farmId: 'saryarka',
        draft: availabilityDraft(productId: empty.productId),
      );
      bool listed() =>
          store.catalogProducts.any((p) => p.id == empty.productId);
      expect(listed(), isTrue);
      await demoLogin(store, 'admin@farm.demo');
      await store.setOfferHidden(
        available.id,
        hidden: true,
        reason: 'Listing verification is required.',
      );
      expect(listed(), isFalse);
      await store.setOfferHidden(
        available.id,
        hidden: false,
        reason: 'Listing verification is complete.',
      );
      expect(listed(), isTrue);
      await store.setAccountBlocked(
        'demo-saryarka',
        blocked: true,
        reason: 'Farm account verification is required.',
      );
      expect(listed(), isFalse);
      await store.setAccountBlocked(
        'demo-saryarka',
        blocked: false,
        reason: 'Farm account verification is complete.',
      );
      expect(listed(), isTrue);
    },
  );

  testWidgets(
    'buyer search, category results and product count update after stock is committed and cancelled',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = await farmerStore(OrderStore());
      final offer = await store.saveOffer(
        farmId: 'bereke',
        draft: availabilityDraft(stock: 10),
      );
      await demoLogin(store);
      await tester.pumpWidget(FarmDirectApp(orderStore: store));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('catalog-search')),
        'Availability onions',
      );
      await tester.pumpAndSettle();
      final card = find.byKey(Key('product-${offer.productId}'));
      expect(card, findsOneWidget);
      expect(find.text('1 product'), findsOneWidget);

      await orderAvailableStock(store, offer, 10);
      await tester.pumpAndSettle();
      expect(card, findsNothing);
      expect(find.text('0 products'), findsOneWidget);
      expect(find.text('No products found'), findsOneWidget);
      await tester.ensureVisible(find.text('Vegetables'));
      await tester.tap(find.text('Vegetables'));
      await tester.pumpAndSettle();
      expect(card, findsNothing);
      expect(find.text('0 products'), findsOneWidget);

      await store.cancel(store.orders.single.id);
      await tester.pumpAndSettle();
      expect(card, findsOneWidget);
      expect(find.text('1 product'), findsOneWidget);
      expect(find.text('No products found'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
