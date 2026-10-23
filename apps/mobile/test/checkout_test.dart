import 'package:farm_direct/main.dart';
import 'package:farm_direct/orders/order.dart';
import 'package:farm_direct/orders/order_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'catalog_test.dart' show openPotatoes;

Future<void> reveal(
  WidgetTester tester,
  Finder finder, {
  bool sheet = false,
}) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: sheet
        ? find.byType(Scrollable).last
        : find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> tapVisible(
  WidgetTester tester,
  Finder finder, {
  bool sheet = false,
}) async {
  await reveal(tester, finder, sheet: sheet);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('buyer checks out, restores history and cancels with fixed terms', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final persistence = MemoryOrderPersistence();
    final store = OrderStore(persistence: persistence);
    await tester.pumpWidget(FarmDirectApp(orderStore: store));
    await tester.pumpAndSettle();
    await openPotatoes(tester);
    await tester.tap(find.text('Delivery available'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('view-potato-3')));
    await tapVisible(tester, find.text('Delivery · ₸2 500'), sheet: true);
    await tapVisible(
      tester,
      find.byKey(const Key('continue-checkout')),
      sheet: true,
    );
    expect(find.text('Complete your order'), findsOneWidget);
    // Required fields above the submit button must validate even after scrolling.
    await tapVisible(tester, find.byKey(const Key('place-order')));
    expect(find.text('Enter the delivery address.'), findsOneWidget);
    expect(find.text('Enter a contact name.'), findsOneWidget);
    expect(
      find.text('Enter a phone number with 10–15 digits.'),
      findsOneWidget,
    );
    expect(store.orders, isEmpty);
    for (final entry in {
      'checkout-address': 'Demo city, Sample Street 1',
      'checkout-name': 'Demo Buyer',
      'checkout-phone': '+7 700 000 00 00',
    }.entries) {
      final field = find.byKey(Key(entry.key));
      await reveal(tester, field);
      await tester.enterText(field, entry.value);
      await tester.pumpAndSettle();
    }
    await tapVisible(tester, find.byKey(const Key('place-order')));
    expect(find.text('Demo order created'), findsOneWidget);
    expect(find.text('Your order number is FD-0001.'), findsOneWidget);
    expect(store.orders, hasLength(1));
    expect(store.orders.single.total, 12000);
    await tapVisible(tester, find.text('View all orders'));
    await tapVisible(tester, find.byKey(const Key('order-FD-0001')));
    await reveal(tester, find.byKey(const Key('saved-order-total')));
    expect(
      tester.widget<Text>(find.byKey(const Key('saved-order-total'))).data,
      '₸12 000',
    );
    await tapVisible(tester, find.byKey(const Key('cancel-order')));
    await tester.tap(find.text('Keep order'));
    await tester.pumpAndSettle();
    expect(store.orders.single.status, OrderStatus.pending);
    await tapVisible(tester, find.byKey(const Key('cancel-order')));
    await tester.tap(find.text('Yes, cancel'));
    await tester.pumpAndSettle();
    expect(store.orders.single.status, OrderStatus.cancelled);
    expect(store.orders.single.total, 12000);
    expect(find.byKey(const Key('cancel-order')), findsNothing);
    expect(tester.takeException(), isNull);

    // Rebuild with a fresh store, as after relaunching the application.
    await tester.pumpWidget(const SizedBox());
    final restored = await OrderStore.restore(persistence);
    await tester.pumpWidget(FarmDirectApp(orderStore: restored));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-orders')));
    await tester.pumpAndSettle();
    expect(find.text('Cancelled'), findsWidgets);
    expect(find.byKey(const Key('order-FD-0001')), findsOneWidget);
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    expect(find.text('No orders in this category'), findsOneWidget);
    await tapVisible(tester, find.text('Show all orders'));
    expect(find.byKey(const Key('order-FD-0001')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty order history offers a way back to products', (
    tester,
  ) async {
    await tester.pumpWidget(const FarmDirectApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-orders')));
    await tester.pumpAndSettle();
    expect(find.text('No orders yet'), findsOneWidget);
    await tapVisible(tester, find.text('Browse products'));
    expect(find.byKey(const Key('catalog-search')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
