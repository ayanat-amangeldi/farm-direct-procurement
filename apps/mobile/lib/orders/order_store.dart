import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import '../catalog/models.dart';
import '../auth/account.dart';
import '../catalog/offer_draft.dart';
import '../catalog/price_change.dart';
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

  List<DemoAccount> _accounts = List.of(demoAccounts);
  List<FarmProfile> _farms = List.of(DemoCatalog.farms);
  DemoAccount? _currentUser;
  bool _authenticating = false;
  DemoAccount? get currentUser => _currentUser;
  List<DemoAccount> get accounts => currentUser?.role == AccountRole.admin
      ? List.unmodifiable(_accounts)
      : const [];
  FarmProfile? get currentFarm {
    for (final farm in _farms) {
      if (farm.id == currentUser?.farmId) return farm;
    }
    return null;
  }

  void _idle() {
    if (_writing || _authenticating) {
      throw const OrderException(
        'Another change is being saved. Please try again.',
      );
    }
  }

  void _requireRole(AccountRole role, {String? farmId}) {
    _idle();
    if (currentUser?.role != role ||
        (farmId != null && currentUser?.farmId != farmId)) {
      throw const OrderException(
        'Your account does not have permission for this action.',
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    _idle();
    _authenticating = true;
    try {
      final normalized = email.trim().toLowerCase();
      // Always derive a hash, including when the address is unknown.
      final selected = _accounts
          .where((a) => a.email == normalized)
          .firstOrNull;
      final valid = await (selected ?? demoAccounts.first).verifies(password);
      if (!valid || selected == null) {
        throw const OrderException('Email or password is incorrect.');
      }
      _currentUser = selected;
      notifyListeners();
    } finally {
      _authenticating = false;
    }
  }

  void signOut() {
    _idle();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required AccountRole role,
    String farmName = '',
    String region = '',
  }) async {
    _idle();
    if (currentUser != null) {
      throw const OrderException('Sign out before creating an account.');
    }
    if (role == AccountRole.admin) {
      throw const OrderException(
        'Administrator accounts cannot be self-registered.',
      );
    }
    final normalized = email.trim().toLowerCase();
    if (nameError(name) != null ||
        emailError(normalized) != null ||
        passwordError(password) != null) {
      throw const OrderException('Check your name, email and password.');
    }
    if (_accounts.any((a) => a.email == normalized)) {
      throw const OrderException(
        'An account already exists for this email. Sign in instead.',
      );
    }
    if (role == AccountRole.farmer &&
        (farmName.trim().length < 2 ||
            farmName.trim().length > 80 ||
            region.trim().length < 2 ||
            region.trim().length > 100)) {
      throw const OrderException('Enter a farm name and region.');
    }
    _authenticating = true;
    try {
      final salt = DemoAccount.newSalt();
      final hash = await DemoAccount.hash(password, salt);
      final farmId = role == AccountRole.farmer
          ? _nextId('farm', _farms.map((f) => f.id))
          : null;
      final account = DemoAccount(
        id: _nextId('account', _accounts.map((a) => a.id)),
        name: name.trim(),
        email: normalized,
        role: role,
        farmId: farmId,
        salt: salt,
        passwordHash: hash,
      );
      await _save(
        _orders,
        accounts: [..._accounts, account],
        farms: [
          ..._farms,
          if (farmId != null)
            FarmProfile(
              id: farmId,
              name: farmName.trim(),
              region: region.trim(),
            ),
        ],
        signedIn: account,
      );
    } finally {
      _authenticating = false;
    }
  }

  final OrderPersistence _persistence;
  final DateTime Function() _now;
  final bool sessionOnly;
  final bool loadFailed;
  List<ProcurementOrder> _orders = [];
  List<PriceChange> _priceHistory = [];
  List<PriceChange> priceHistoryFor(String offerId) => List.unmodifiable(
    _priceHistory.where((item) => item.offerId == offerId).toList().reversed,
  );
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
            order.offerId == offerId &&
            order.status != OrderStatus.cancelled &&
            order.status != OrderStatus.rejected,
      )
      .fold(0, (sum, order) => sum + order.quantityKg);
  bool _writing = false;

  bool _canRead(ProcurementOrder order) => switch (currentUser?.role) {
    AccountRole.admin => true,
    AccountRole.buyer => order.buyerId == currentUser!.id,
    AccountRole.farmer => order.farmId == currentUser!.farmId,
    null => false,
  };
  List<ProcurementOrder> get orders =>
      List.unmodifiable(_orders.where(_canRead));
  ProcurementOrder? find(String id) {
    for (final order in _orders) {
      if (order.id == id && _canRead(order)) return order;
    }
    return null;
  }

  static Future<OrderStore> restore(OrderPersistence persistence) async {
    final store = OrderStore(persistence: persistence, sessionOnly: false);
    final raw = await persistence.read();
    if (raw == null) return store;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    if (![1, 2, 3, 4].contains(data['version'])) {
      throw const FormatException('Unsupported order history.');
    }
    if (data['version'] == 4) {
      store._accounts = (data['accounts'] as List)
          .map(
            (item) =>
                DemoAccount.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
      store._farms = (data['farms'] as List).map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final farm = FarmProfile(
          id: map['id'] as String,
          name: map['name'] as String,
          region: map['region'] as String,
        );
        if (farm.id.isEmpty ||
            farm.name.trim().length < 2 ||
            farm.name.length > 80 ||
            farm.region.trim().length < 2 ||
            farm.region.length > 100) {
          throw const FormatException('Invalid saved farm.');
        }
        return farm;
      }).toList();
      if (store._accounts.map((a) => a.id).toSet().length !=
              store._accounts.length ||
          store._accounts.map((a) => a.email).toSet().length !=
              store._accounts.length ||
          store._farms.map((f) => f.id).toSet().length != store._farms.length ||
          !store._accounts.any((a) => a.role == AccountRole.admin) ||
          store._accounts.any(
            (a) =>
                a.role == AccountRole.farmer &&
                !store._farms.any((f) => f.id == a.farmId),
          ) ||
          store._accounts
                  .where((a) => a.role == AccountRole.farmer)
                  .map((a) => a.farmId)
                  .toSet()
                  .length !=
              store._accounts
                  .where((a) => a.role == AccountRole.farmer)
                  .length) {
        throw const FormatException('Inconsistent saved accounts.');
      }
    }
    if ([2, 3, 4].contains(data['version'])) {
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
                !store._farms.any((farm) => farm.id == item.farmId),
          )) {
        throw const FormatException('Inconsistent saved catalog.');
      }
    }
    store._orders = (data['orders'] as List).map((json) {
      final values = Map<String, dynamic>.from(json as Map);
      if (data['version'] == 4 && values['buyerId'] == null) {
        throw const FormatException('Missing saved buyer ownership.');
      }
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
    if ([3, 4].contains(data['version'])) {
      if (data['priceHistory'] is! List) {
        throw const FormatException('Missing saved price history.');
      }
      store._priceHistory = (data['priceHistory'] as List)
          .map(
            (item) =>
                PriceChange.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
      if (store._priceHistory.map((item) => item.id).toSet().length !=
              store._priceHistory.length ||
          store._priceHistory.any(
            (item) => store.offer(item.offerId)?.farmId != item.farmId,
          )) {
        throw const FormatException('Inconsistent saved price history.');
      }
    }
    if (store._orders.any(
      (order) => !store._accounts.any(
        (a) => a.id == order.buyerId && a.role == AccountRole.buyer,
      ),
    )) {
      throw const FormatException('Missing buyer for a saved order.');
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
    _requireRole(AccountRole.farmer, farmId: farmId);
    if (_writing) {
      throw const OrderException(
        'Another change is being saved. Please try again.',
      );
    }
    FarmProfile? farm;
    for (final profile in _farms) {
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
    final nextHistory = List<PriceChange>.of(_priceHistory);
    if (existing == null ||
        existing.pricePerKg != saved.pricePerKg ||
        existing.deliveryFee != saved.deliveryFee) {
      nextHistory.add(
        PriceChange(
          id: _nextId('price-change', _priceHistory.map((item) => item.id)),
          offerId: saved.id,
          farmId: saved.farmId,
          at: _now(),
          oldPrice: existing?.pricePerKg,
          newPrice: saved.pricePerKg,
          oldDeliveryFee: existing?.deliveryFee,
          newDeliveryFee: saved.deliveryFee,
        ),
      );
    }
    await _save(
      _orders,
      products: nextProducts,
      offers: nextOffers,
      priceHistory: nextHistory,
    );
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
    _requireRole(AccountRole.buyer);
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
      buyerId: currentUser!.id,
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
      : List.unmodifiable(orders.where((order) => order.farmId == farmId));

  Future<void> confirm(String id, {required String farmId}) =>
      _farmerTransition(id, farmId: farmId, target: OrderStatus.confirmed);
  Future<void> markReady(String id, {required String farmId}) =>
      _farmerTransition(id, farmId: farmId, target: OrderStatus.ready);
  Future<void> complete(String id, {required String farmId}) =>
      _farmerTransition(id, farmId: farmId, target: OrderStatus.completed);
  Future<void> reject(
    String id, {
    required String farmId,
    required String reason,
  }) => _farmerTransition(
    id,
    farmId: farmId,
    target: OrderStatus.rejected,
    reason: reason,
  );

  Future<void> _farmerTransition(
    String id, {
    required String farmId,
    required OrderStatus target,
    String reason = '',
  }) async {
    if (_writing) {
      throw const OrderException(
        'Another change is being saved. Please try again.',
      );
    }
    _requireRole(AccountRole.farmer, farmId: farmId);
    final order = find(id);
    if (farmId.isEmpty || order == null || order.farmId != farmId) {
      throw const OrderException(
        'This order is not available to the selected farm.',
      );
    }
    final allowed = switch (target) {
      OrderStatus.confirmed => order.status == OrderStatus.pending,
      OrderStatus.ready => order.status == OrderStatus.confirmed,
      OrderStatus.completed => order.status == OrderStatus.ready,
      OrderStatus.rejected => order.canReject,
      _ => false,
    };
    if (!allowed) {
      throw const OrderException(
        'This status change is not available for this order.',
      );
    }
    if (target == OrderStatus.rejected &&
        rejectionReasonError(reason) != null) {
      throw OrderException(rejectionReasonError(reason)!);
    }
    final at = _now();
    final changed = switch (target) {
      OrderStatus.confirmed => order.confirmed(at),
      OrderStatus.ready => order.markedReady(at),
      OrderStatus.completed => order.completed(at),
      OrderStatus.rejected => order.rejected(at, reason.trim()),
      _ => throw const OrderException('Unsupported order status.'),
    };
    await _save(_orders.map((item) => item.id == id ? changed : item).toList());
  }

  Future<void> cancel(String id) async {
    _requireRole(AccountRole.buyer);
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
      _orders
          .map((item) => item.id == id ? item.cancelled(_now()) : item)
          .toList(),
    );
  }

  Future<void> _save(
    List<ProcurementOrder> candidate, {
    List<Product>? products,
    List<FarmerOffer>? offers,
    List<PriceChange>? priceHistory,
    List<DemoAccount>? accounts,
    List<FarmProfile>? farms,
    DemoAccount? signedIn,
  }) async {
    final nextProducts = products ?? _products;
    final nextOffers = offers ?? _offers;
    final nextHistory = priceHistory ?? _priceHistory;
    _writing = true;
    try {
      await _persistence.write(
        jsonEncode({
          'version': 4,
          'accounts': (accounts ?? _accounts).map((a) => a.toJson()).toList(),
          'farms': (farms ?? _farms)
              .map((f) => {'id': f.id, 'name': f.name, 'region': f.region})
              .toList(),
          'priceHistory': nextHistory.map((item) => item.toJson()).toList(),
          'products': nextProducts.map((item) => item.toJson()).toList(),
          'offers': nextOffers.map((item) => item.toJson()).toList(),
          'orders': candidate.map((order) => order.toJson()).toList(),
        }),
      );
      _accounts = accounts ?? _accounts;
      _farms = farms ?? _farms;
      _currentUser = signedIn ?? _currentUser;
      _orders = candidate;
      _products = nextProducts;
      _offers = nextOffers;
      _priceHistory = nextHistory;
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
