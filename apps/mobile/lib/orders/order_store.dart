import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../catalog/models.dart';
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
    if (data['version'] != 1) {
      throw const FormatException('Unsupported order history.');
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

  int availableKg(FarmerOffer offer) {
    final committed = _orders
        .where(
          (order) =>
              order.offerId == offer.id &&
              order.status != OrderStatus.cancelled,
        )
        .fold(0, (sum, order) => sum + order.quantityKg);
    return math.max(0, offer.availableKg - committed);
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

  Future<void> _save(List<ProcurementOrder> candidate) async {
    _writing = true;
    try {
      await _persistence.write(
        jsonEncode({
          'version': 1,
          'orders': candidate.map((order) => order.toJson()).toList(),
        }),
      );
      _orders = candidate;
      notifyListeners();
    } catch (_) {
      throw const OrderException(
        'Could not save the demo order. Please try again.',
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
