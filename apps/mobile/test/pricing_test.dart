import 'package:farm_direct/catalog/demo_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final offers = const DemoCatalog().offersFor('potatoes');
  final pickup = offers.first;
  final delivery = offers[1];

  test('quoted total includes only the chosen disclosed delivery charge', () {
    expect(delivery.quote(kg: 50, delivery: false).total, 10000);
    expect(delivery.quote(kg: 50, delivery: true).total, 11800);
    expect(pickup.quote(kg: 20, delivery: false).total, 3600);
  });

  test('invalid quantities and unavailable delivery cannot produce quotes', () {
    for (final kg in [0, -1, 19, 501]) {
      expect(() => pickup.quote(kg: kg, delivery: false), throwsArgumentError);
    }
    expect(() => pickup.quote(kg: 20, delivery: true), throwsArgumentError);
    expect(pickup.quote(kg: 500, delivery: false).total, 90000);
  });

  test('demo product ids and offer constraints are internally consistent', () {
    final ids = DemoCatalog.products.map((p) => p.id).toSet();
    expect(ids.length, DemoCatalog.products.length);
    expect(
      DemoCatalog.offers.map((o) => o.id).toSet().length,
      DemoCatalog.offers.length,
    );
    for (final product in DemoCatalog.products) {
      expect(const DemoCatalog().offersFor(product.id), isNotEmpty);
    }
    for (final offer in DemoCatalog.offers) {
      expect(ids, contains(offer.productId));
      expect(offer.minimumKg, greaterThan(0));
      expect(offer.availableKg, greaterThanOrEqualTo(offer.minimumKg));
      expect(offer.pricePerKg, greaterThan(0));
    }
  });
}
