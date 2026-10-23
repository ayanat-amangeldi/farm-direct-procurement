import 'models.dart';

String? wholeNumberError(
  String? value, {
  bool allowZero = false,
  int max = 1000000,
}) {
  final text = value?.trim() ?? '';
  final number = int.tryParse(text);
  if (!RegExp(r'^\d+$').hasMatch(text) ||
      number == null ||
      number < (allowZero ? 0 : 1) ||
      number > max) {
    return 'Enter a whole number from ${allowZero ? 0 : 1} to $max.';
  }
  return null;
}

String categoryLabel(ProductCategory category) => switch (category) {
  ProductCategory.vegetables => 'Vegetables',
  ProductCategory.fruits => 'Fruits',
  ProductCategory.grains => 'Grains',
};

/// Editable terms of one farm's offer. A null product ID creates a new type.
class OfferDraft {
  const OfferDraft({
    required this.productId,
    required this.pricePerKg,
    required this.totalStockKg,
    required this.minimumKg,
    required this.deliveryFee,
    required this.location,
    required this.description,
    this.newProductName = '',
    this.newProductDescription = '',
    this.newProductCategory = ProductCategory.vegetables,
  });
  final String? productId;
  final int pricePerKg;
  final int totalStockKg;
  final int minimumKg;
  final int? deliveryFee;
  final String location;
  final String description;
  final String newProductName;
  final String newProductDescription;
  final ProductCategory newProductCategory;

  String? validate({required int reservedKg}) {
    if (pricePerKg <= 0 ||
        pricePerKg > 10000000 ||
        totalStockKg < 0 ||
        totalStockKg > 1000000 ||
        minimumKg <= 0 ||
        minimumKg > 1000000 ||
        (deliveryFee != null &&
            (deliveryFee! < 0 || deliveryFee! > 10000000))) {
      return 'Check price, quantity and delivery fee limits.';
    }
    if (totalStockKg < reservedKg) {
      return '$reservedKg kg is already committed to saved orders. Total stock cannot be lower.';
    }
    if (totalStockKg > 0 && minimumKg > totalStockKg) {
      return 'Minimum order cannot exceed total stock.';
    }
    if (location.trim().length < 2 || location.trim().length > 100) {
      return 'Enter a pickup region of 2–100 characters.';
    }
    if (description.trim().length > 500) {
      return 'Use at most 500 characters for offer details.';
    }
    if (productId == null &&
        (newProductName.trim().length < 2 ||
            newProductName.trim().length > 60 ||
            newProductDescription.trim().length > 160)) {
      return 'Enter a product name of 2–60 characters and a description of at most 160 characters.';
    }
    return null;
  }
}
