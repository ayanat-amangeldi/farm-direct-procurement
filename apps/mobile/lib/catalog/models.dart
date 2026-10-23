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

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category.name,
  };
  factory Product.fromJson(Map<String, dynamic> json) {
    final product = Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: ProductCategory.values.byName(json['category'] as String),
    );
    if (product.id.isEmpty ||
        product.name.trim().length < 2 ||
        product.name.length > 60 ||
        product.description.length > 160) {
      throw const FormatException('Invalid saved product.');
    }
    return product;
  }
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
    this.description = '',
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
  final String description;

  Map<String, Object?> toJson() => {
    'id': id,
    'productId': productId,
    'farmId': farmId,
    'farmName': farmName,
    'location': location,
    'pricePerKg': pricePerKg,
    'availableKg': availableKg,
    'minimumKg': minimumKg,
    'deliveryFee': deliveryFee,
    'description': description,
  };

  factory FarmerOffer.fromJson(Map<String, dynamic> json) {
    final fee = json['deliveryFee'] as int?;
    final offer = FarmerOffer(
      id: json['id'] as String,
      productId: json['productId'] as String,
      farmId: json['farmId'] as String,
      farmName: json['farmName'] as String,
      location: json['location'] as String,
      pricePerKg: json['pricePerKg'] as int,
      availableKg: json['availableKg'] as int,
      minimumKg: json['minimumKg'] as int,
      deliveryFee: fee,
      description: json['description'] as String? ?? '',
    );
    if (offer.id.isEmpty ||
        offer.pricePerKg <= 0 ||
        offer.pricePerKg > 10000000 ||
        offer.availableKg < 0 ||
        offer.availableKg > 1000000 ||
        offer.minimumKg <= 0 ||
        offer.minimumKg > 1000000 ||
        (offer.availableKg > 0 && offer.minimumKg > offer.availableKg) ||
        (fee != null && (fee < 0 || fee > 10000000)) ||
        offer.location.trim().length < 2 ||
        offer.location.length > 100 ||
        offer.description.length > 500) {
      throw const FormatException('Invalid saved farmer offer.');
    }
    return offer;
  }

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
