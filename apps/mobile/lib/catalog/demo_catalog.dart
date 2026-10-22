import 'models.dart';

/// Fictional fixtures for interface development, not live market prices.
class DemoCatalog {
  const DemoCatalog();

  List<FarmerOffer> offersFor(String productId) =>
      offers.where((offer) => offer.productId == productId).toList();

  int startingPrice(String productId) => offersFor(
    productId,
  ).map((offer) => offer.pricePerKg).reduce((a, b) => a < b ? a : b);

  static const products = [
    Product(
      id: 'potatoes',
      name: 'Potatoes',
      description: 'Everyday essentials',
      category: ProductCategory.vegetables,
    ),
    Product(
      id: 'carrots',
      name: 'Carrots',
      description: 'Colour for your kitchen',
      category: ProductCategory.vegetables,
    ),
    Product(
      id: 'tomatoes',
      name: 'Tomatoes',
      description: 'For salads and cooking',
      category: ProductCategory.vegetables,
    ),
    Product(
      id: 'cucumbers',
      name: 'Cucumbers',
      description: 'A crisp, green favourite',
      category: ProductCategory.vegetables,
    ),
    Product(
      id: 'apples',
      name: 'Apples',
      description: 'From local orchards',
      category: ProductCategory.fruits,
    ),
    Product(
      id: 'wheat',
      name: 'Wheat',
      description: 'Grain from the grower',
      category: ProductCategory.grains,
    ),
  ];

  static const offers = [
    FarmerOffer(
      id: 'potato-1',
      productId: 'potatoes',
      farmName: 'Saryarka Farm',
      location: 'Akmola region',
      pricePerKg: 180,
      availableKg: 500,
      minimumKg: 20,
      deliveryFee: null,
    ),
    FarmerOffer(
      id: 'potato-2',
      productId: 'potatoes',
      farmName: 'Green Valley Farm',
      location: 'Almaty region',
      pricePerKg: 200,
      availableKg: 300,
      minimumKg: 10,
      deliveryFee: 1800,
    ),
    FarmerOffer(
      id: 'potato-3',
      productId: 'potatoes',
      farmName: 'Bereke Family Farm',
      location: 'Karaganda region',
      pricePerKg: 190,
      availableKg: 800,
      minimumKg: 50,
      deliveryFee: 2500,
    ),
    FarmerOffer(
      id: 'carrot-1',
      productId: 'carrots',
      farmName: 'Saryarka Farm',
      location: 'Akmola region',
      pricePerKg: 160,
      availableKg: 400,
      minimumKg: 20,
      deliveryFee: null,
    ),
    FarmerOffer(
      id: 'carrot-2',
      productId: 'carrots',
      farmName: 'Bereke Family Farm',
      location: 'Karaganda region',
      pricePerKg: 175,
      availableKg: 250,
      minimumKg: 10,
      deliveryFee: 2000,
    ),
    FarmerOffer(
      id: 'tomato-1',
      productId: 'tomatoes',
      farmName: 'Green Valley Farm',
      location: 'Almaty region',
      pricePerKg: 480,
      availableKg: 180,
      minimumKg: 5,
      deliveryFee: 1800,
    ),
    FarmerOffer(
      id: 'tomato-2',
      productId: 'tomatoes',
      farmName: 'Sunrise Farm',
      location: 'Turkistan region',
      pricePerKg: 450,
      availableKg: 300,
      minimumKg: 20,
      deliveryFee: null,
    ),
    FarmerOffer(
      id: 'cucumber-1',
      productId: 'cucumbers',
      farmName: 'Sunrise Farm',
      location: 'Turkistan region',
      pricePerKg: 350,
      availableKg: 200,
      minimumKg: 10,
      deliveryFee: 1500,
    ),
    FarmerOffer(
      id: 'cucumber-2',
      productId: 'cucumbers',
      farmName: 'Green Valley Farm',
      location: 'Almaty region',
      pricePerKg: 380,
      availableKg: 150,
      minimumKg: 5,
      deliveryFee: 1800,
    ),
    FarmerOffer(
      id: 'apple-1',
      productId: 'apples',
      farmName: 'Alatau Orchard',
      location: 'Almaty region',
      pricePerKg: 420,
      availableKg: 600,
      minimumKg: 10,
      deliveryFee: 1500,
    ),
    FarmerOffer(
      id: 'apple-2',
      productId: 'apples',
      farmName: 'Green Valley Farm',
      location: 'Almaty region',
      pricePerKg: 450,
      availableKg: 250,
      minimumKg: 5,
      deliveryFee: null,
    ),
    FarmerOffer(
      id: 'wheat-1',
      productId: 'wheat',
      farmName: 'Saryarka Farm',
      location: 'Akmola region',
      pricePerKg: 110,
      availableKg: 2000,
      minimumKg: 100,
      deliveryFee: null,
    ),
  ];
}
