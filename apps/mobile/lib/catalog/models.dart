enum ProductCategory { vegetables, fruits, grains }

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  final String id;
  final String name;
  final String description;
  final ProductCategory category;
}

class FarmProfile {
  const FarmProfile({
    required this.id,
    required this.name,
    required this.region,
  });
  final String id;
  final String name;
  final String region;
}

class FarmerOffer {
  const FarmerOffer({
    required this.id,
    required this.productId,
    required this.farmId,
    required this.farmName,
    required this.location,
    required this.pricePerKg,
    required this.availableKg,
    required this.minimumKg,
    required this.deliveryFee,
  });

  final String id;
  final String productId;
  final String farmId;
  final String farmName;
  final String location;
  // All amounts are integer KZT. No floating-point arithmetic is used.
  final int pricePerKg;
  final int availableKg;
  final int minimumKg;
  // Null means pickup only; zero would mean free delivery.
  final int? deliveryFee;

  String? quantityError(int? kg) {
    if (kg == null || kg <= 0) return 'Enter a whole number greater than zero.';
    if (kg < minimumKg) return 'Minimum order is $minimumKg kg.';
    if (kg > availableKg) return 'Only $availableKg kg is available.';
    return null;
  }

  PriceQuote quote({required int kg, required bool delivery}) {
    final error = quantityError(kg);
    if (error != null) throw ArgumentError(error);
    if (delivery && deliveryFee == null) {
      throw ArgumentError('This offer is pickup only.');
    }
    return PriceQuote(
      productSubtotal: pricePerKg * kg,
      delivery: delivery ? deliveryFee! : 0,
    );
  }
}

class PriceQuote {
  const PriceQuote({required this.productSubtotal, required this.delivery});
  final int productSubtotal;
  final int delivery;
  int get total => productSubtotal + delivery;
}

String money(int amount) =>
    '₸${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]} ')}';
