import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import '../catalog/models.dart';
import '../catalog/offer_draft.dart';
import '../catalog/demo_catalog.dart';
import 'order.dart';

abstract interface class OrderPersistence {
  Future<String?> read();
  Future<void> write(String value);
}

class MemoryOrderPersistence implements OrderPersistence {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async => this.value = value;
}

class OrderException implements Exception {
  const OrderException(this.message);
  final String message;
  @override
  String toString() => message;
}

class OrderStore extends ChangeNotifier {
  OrderStore({
    OrderPersistence? persistence,
    DateTime Function()? now,
    this.sessionOnly = true,
    this.loadFailed = false,
  }) : _persistence = persistence ?? MemoryOrderPersistence(),
       _now = now ?? DateTime.now;

  final OrderPersistence _persistence;
  final DateTime Function() _now;
  final bool sessionOnly;
  final bool loadFailed;
  List<ProcurementOrder> _orders = [];
  List<Product> _products = List.of(DemoCatalog.products);
  List<FarmerOffer> _offers = List.of(DemoCatalog.offers);

  List<Product> get products => List.unmodifiable(_products);
  List<FarmerOffer> get offers => List.unmodifiable(_offers);
  Product? product(String id) {
    for (final item in _products) {
      if (item.id == id) return item;
    }
    return null;
  }

  FarmerOffer? offer(String id) {
    for (final item in _offers) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<FarmerOffer> offersFor(String productId) =>
      List.unmodifiable(_offers.where((item) => item.productId == productId));
  List<FarmerOffer> farmOffers(String farmId) =>
      List.unmodifiable(_offers.where((item) => item.farmId == farmId));
  int reservedKg(String offerId) => _orders
      .where(
        (order) =>
            order.offerId == offerId && order.status != OrderStatus.cancelled,
      )
      .fold(0, (sum, order) => sum + order.quantityKg);
  bool _writing = false;

  List<ProcurementOrder> get orders => List.unmodifiable(_orders);
  ProcurementOrder? find(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  static Future<OrderStore> restore(OrderPersistence persistence) async {
    final store = OrderStore(persistence: persistence, sessionOnly: false);
    final raw = await persistence.read();
    if (raw == null) return store;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    if (data['version'] != 1 && data['version'] != 2) {
      throw const FormatException('Unsupported order history.');
    }
    if (data['version'] == 2) {
      if (data['products'] is! List || data['offers'] is! List) {
        throw const FormatException('Missing saved catalog.');
      }
      store._products = (data['products'] as List)
          .map(
            (item) => Product.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
      store._offers = (data['offers'] as List)
          .map(
            (item) =>
                FarmerOffer.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
      final productIds = store._products.map((item) => item.id).toSet();
      if (productIds.length != store._products.length ||
          store._products
                  .map((item) => item.name.trim().toLowerCase())
                  .toSet()
                  .length !=
              store._products.length ||
          store._offers.map((item) => item.id).toSet().length !=
              store._offers.length ||
          store._offers
                  .map((item) => '${item.farmId}/${item.productId}')
                  .toSet()
                  .length !=
              store._offers.length ||
          store._offers.any(
            (item) =>
                !productIds.contains(item.productId) ||
                !DemoCatalog.farms.any((farm) => farm.id == item.farmId),
          )) {
        throw const FormatException('Inconsistent saved catalog.');
      }
    }
    store._orders = (data['orders'] as List).map((json) {
      final values = Map<String, dynamic>.from(json as Map);
      // Version-1 orders predate farm IDs. Match known offer IDs only;
      // an unknown offer stays buyer-visible but has no farmer owner.
      if (values['farmId'] == null) {
        values['farmId'] = '';
        for (final offer in DemoCatalog.offers) {
          if (offer.id == values['offerId']) {
            values['farmId'] = offer.farmId;
            break;
          }
        }
      }
      return ProcurementOrder.fromJson(values);
    }).toList();
    if (store._orders.map((order) => order.id).toSet().length !=
        store._orders.length) {
      throw const FormatException('Duplicate order numbers.');
    }
    return store;
  }

  int availableKg(FarmerOffer selected) {
    final current = offer(selected.id);
    return current == null
        ? 0
        : math.max(0, current.availableKg - reservedKg(current.id));
  }

  Future<FarmerOffer> saveOffer({
    required String farmId,
    required OfferDraft draft,
    String? offerId,
  }) async {
    if (_writing) {
      throw const OrderException(
        'Another change is being saved. Please try again.',
      );
    }
    FarmProfile? farm;
    for (final profile in DemoCatalog.farms) {
      if (profile.id == farmId) farm = profile;
    }
    if (farm == null) throw const OrderException('Select a valid demo farm.');
    final existing = offerId == null ? null : offer(offerId);
    if (offerId != null && (existing == null || existing.farmId != farmId)) {
      throw const OrderException(
        'This offer is not available to the selected farm.',
      );
    }
    if (existing != null && draft.productId != existing.productId) {
      throw const OrderException(
        'The product type of a published offer cannot be changed.',
      );
    }
    final error = draft.validate(
      reservedKg: existing == null ? 0 : reservedKg(existing.id),
    );
    if (error != null) throw OrderException(error);
    final nextProducts = List<Product>.of(_products);
    Product? selectedProduct;
    if (draft.productId == null) {
      if (_products.any(
        (item) =>
            item.name.trim().toLowerCase() ==
            draft.newProductName.trim().toLowerCase(),
      )) {
        throw const OrderException(
          'This product type already exists. Select it from the list.',
        );
      }
      selectedProduct = Product(
        id: _nextId('custom-product', _products.map((item) => item.id)),
        name: draft.newProductName.trim(),
        description: draft.newProductDescription.trim(),
        category: draft.newProductCategory,
      );
      nextProducts.add(selectedProduct);
    } else {
      selectedProduct = product(draft.productId!);
    }
    if (selectedProduct == null) {
      throw const OrderException('Select a valid product type.');
    }
    if (_offers.any(
      (item) =>
          item.farmId == farmId &&
          item.productId == selectedProduct!.id &&
          item.id != offerId,
    )) {
      throw const OrderException(
        'Your farm already has an offer for this product. Edit that offer instead.',
      );
    }
    final saved = FarmerOffer(
      id:
          existing?.id ??
          _nextId('custom-offer', _offers.map((item) => item.id)),
      productId: selectedProduct.id,
      farmId: farm.id,
      farmName: farm.name,
      location: draft.location.trim(),
      pricePerKg: draft.pricePerKg,
      availableKg: draft.totalStockKg,
      minimumKg: draft.minimumKg,
      deliveryFee: draft.deliveryFee,
      description: draft.description.trim(),
    );
    final nextOffers = existing == null
        ? [..._offers, saved]
        : _offers.map((item) => item.id == existing.id ? saved : item).toList();
    await _save(_orders, products: nextProducts, offers: nextOffers);
    return saved;
  }

  String _nextId(String prefix, Iterable<String> ids) {
    var sequence = 1;
    for (final id in ids.where((id) => id.startsWith('$prefix-'))) {
      sequence = math.max(
        sequence,
        (int.tryParse(id.substring(prefix.length + 1)) ?? 0) + 1,
      );
    }
    return '$prefix-${sequence.toString().padLeft(4, '0')}';
  }

  Future<ProcurementOrder> place({
    required Product product,
    required FarmerOffer offer,
    required int kg,
    required bool delivery,
    required String contactName,
    required String phone,
    required String address,
    required String note,
  }) async {
    if (_writing) {
      throw const OrderException(
        'Another change is being saved. Please try again.',
      );
    }
    final current = this.offer(offer.id);
    if (current == null || !mapEquals(current.toJson(), offer.toJson())) {
      throw const OrderException(
        'This offer has changed. Reopen it to review the latest price and terms.',
      );
    }
    final error = availableQuantityError(offer, kg, availableKg(offer));
    if (error != null) throw OrderException(error);
    if (offer.productId != product.id) {
      throw const OrderException('The offer does not match this product.');
    }
    if (nameError(contactName) != null ||
        phoneError(phone) != null ||
        (delivery && addressError(address) != null)) {
      throw const OrderException('Check the contact and delivery details.');
    }
    if (note.trim().length > 500) {
      throw const OrderException('Use at most 500 characters for the note.');
    }
    if (delivery && offer.deliveryFee == null) {
      throw const OrderException('This offer is pickup only.');
    }
    final quote = offer.quote(kg: kg, delivery: delivery);
    var sequence = 1;
    for (final existing in _orders) {
      sequence = math.max(
        sequence,
        (int.tryParse(existing.id.split('-').last) ?? 0) + 1,
      );
    }
    final order = ProcurementOrder(
      id: 'FD-${sequence.toString().padLeft(4, '0')}',
      createdAt: _now(),
      productId: product.id,
      productName: product.name,
      offerId: offer.id,
      farmId: offer.farmId,
      farmName: offer.farmName,
      farmRegion: offer.location,
      quantityKg: kg,
      unitPrice: offer.pricePerKg,
      delivery: delivery,
      deliveryFee: quote.delivery,
      contactName: contactName.trim(),
      phone: phone.trim(),
      address: delivery ? address.trim() : '',
      note: note.trim(),
      status: OrderStatus.pending,
    );
    await _save([order, ..._orders]);
    return order;
  }

  List<ProcurementOrder> ordersForFarm(String farmId) => farmId.isEmpty
      ? const []
      : List.unmodifiable(_orders.where((order) => order.farmId == farmId));

  Future<void> confirm(String id, {required String farmId}) async {
    if (_writing) {
      throw const OrderException(
        'Another change is being saved. Please try again.',
      );
    }
    final order = find(id);
    if (farmId.isEmpty || order == null || order.farmId != farmId) {
      throw const OrderException(
        'This order is not available to the selected farm.',
      );
    }
    if (order.status != OrderStatus.pending) {
      throw const OrderException('Only an awaiting order can be confirmed.');
    }
    final confirmed = order.confirmed(_now());
    await _save(
      _orders.map((item) => item.id == id ? confirmed : item).toList(),
    );
  }

  Future<void> cancel(String id) async {
    if (_writing) {
      throw const OrderException(
        'Another change is being saved. Please try again.',
      );
    }
    final order = find(id);
    if (order == null || !order.canCancel) {
      throw const OrderException('This order cannot be cancelled.');
    }
    await _save(
      _orders.map((item) => item.id == id ? item.cancelled() : item).toList(),
    );
  }

  Future<void> _save(
    List<ProcurementOrder> candidate, {
    List<Product>? products,
    List<FarmerOffer>? offers,
  }) async {
    final nextProducts = products ?? _products;
    final nextOffers = offers ?? _offers;
    _writing = true;
    try {
      await _persistence.write(
        jsonEncode({
          'version': 2,
          'products': nextProducts.map((item) => item.toJson()).toList(),
          'offers': nextOffers.map((item) => item.toJson()).toList(),
          'orders': candidate.map((order) => order.toJson()).toList(),
        }),
      );
      _orders = candidate;
      _products = nextProducts;
      _offers = nextOffers;
      notifyListeners();
    } catch (_) {
      throw const OrderException(
        'Could not save the change. Please try again.',
      );
    } finally {
      _writing = false;
    }
  }
}

class OrderScope extends InheritedNotifier<OrderStore> {
  const OrderScope({required OrderStore store, required super.child, super.key})
    : super(notifier: store);
  static OrderStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<OrderScope>();
    assert(scope != null, 'OrderScope is required.');
    return scope!.notifier!;
  }
}
