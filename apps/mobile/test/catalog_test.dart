import 'package:farm_direct/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openPotatoes(WidgetTester tester) async {
  final card = find.byKey(const Key('product-potatoes'));
  await tester.scrollUntilVisible(
    card,
    180,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(card);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('Delivery available'),
    160,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  Future<void> launch(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const FarmDirectApp());
    await tester.pumpAndSettle();
  }

  testWidgets(
    'search and category filters combine and reset without a dead end',
    (tester) async {
      await launch(tester);
      await tester.enterText(
        find.byKey(const Key('catalog-search')),
        '  potato  ',
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('product-potatoes')), findsOneWidget);
      expect(find.byKey(const Key('product-carrots')), findsNothing);
      await tester.ensureVisible(find.text('Fruits'));
      await tester.tap(find.text('Fruits'));
      await tester.pumpAndSettle();
      expect(find.text('No products found'), findsOneWidget);
      await tester.ensureVisible(find.text('Reset filters'));
      await tester.tap(find.text('Reset filters'));
      await tester.pumpAndSettle();
      expect(find.text('6 products'), findsOneWidget);
      expect(find.text('No products found'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'product opens its farmers and delivery filter excludes pickup-only farms',
    (tester) async {
      await launch(tester);
      await openPotatoes(tester);
      expect(find.text('3 offers available'), findsOneWidget);
      expect(find.text('Saryarka Farm'), findsOneWidget);
      await tester.tap(find.text('Delivery available'));
      await tester.pumpAndSettle();
      expect(find.text('2 offers available'), findsOneWidget);
      expect(find.text('Saryarka Farm'), findsNothing);
      expect(find.text('Bereke Family Farm'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'price preview validates quantity and updates total when delivery is chosen',
    (tester) async {
      await launch(tester);
      await openPotatoes(tester);
      await tester.tap(find.text('Delivery available'));
      await tester.pumpAndSettle();
      final button = find.byKey(const Key('view-potato-3'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Your price, explained'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('quote-total'))).data,
        '₸9 500',
      );
      await tester.ensureVisible(find.text('Delivery · ₸2 500'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delivery · ₸2 500'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const Key('quote-total'))).data,
        '₸12 000',
      );
      await tester.enterText(find.byKey(const Key('offer-quantity')), '49');
      await tester.pumpAndSettle();
      expect(find.text('Minimum order is 50 kg.'), findsOneWidget);
      expect(find.byKey(const Key('quote-total')), findsNothing);
      await tester.enterText(find.byKey(const Key('offer-quantity')), '801');
      await tester.pumpAndSettle();
      expect(find.text('Only 800 kg is available.'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('offer-quantity')), '100');
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const Key('quote-total'))).data,
        '₸21 500',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('delivery-only empty state can return to pickup offers', (
    tester,
  ) async {
    await launch(tester);
    await tester.enterText(find.byKey(const Key('catalog-search')), 'wheat');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('product-wheat')));
    await tester.tap(find.byKey(const Key('product-wheat')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Delivery available'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delivery available'));
    await tester.pumpAndSettle();
    expect(find.text('No delivery offers yet'), findsOneWidget);
    await tester.ensureVisible(find.text('Reset filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.text('1 offer available'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('farm-name sorting changes the first offer', (tester) async {
    await launch(tester);
    await openPotatoes(tester);
    await tester.tap(find.byTooltip('Sort farmer offers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farm name').last);
    await tester.pumpAndSettle();
    expect(find.text('Bereke Family Farm'), findsOneWidget);
    final renderedOffers = tester.widgetList<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.key.toString().contains('offer-potato-'),
      ),
    );
    expect(renderedOffers.first.key, const Key('offer-potato-3'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog remains usable on a narrow screen with larger text', (
    tester,
  ) async {
    await launch(tester, size: const Size(320, 720));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 720),
            textScaler: TextScaler.linear(1.5),
          ),
          child: const FarmDirectApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('product-potatoes')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      MediaQuery.textScalerOf(tester.element(find.text('Potatoes'))).scale(14),
      21,
    );
    expect(tester.takeException(), isNull);
  });
}
