import '../catalog/models.dart';

enum OrderStatus {
  pending('Awaiting confirmation'),
  confirmed('Confirmed'),
  ready('Ready'),
  completed('Completed'),
  cancelled('Cancelled'),
  rejected('Rejected');

  const OrderStatus(this.label);
  final String label;
}

String? nameError(String? value) {
  final name = value?.trim() ?? '';
  if (name.length < 2) return 'Enter a contact name.';
  if (name.length > 80) return 'Use at most 80 characters.';
  return null;
}

String? phoneError(String? value) {
  final phone = value?.trim() ?? '';
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (!RegExp(r'^\+?[\d\s()-]+$').hasMatch(phone) ||
      digits.length < 10 ||
      digits.length > 15) {
    return 'Enter a phone number with 10–15 digits.';
  }
  return null;
}

String? addressError(String? value) {
  final address = value?.trim() ?? '';
  if (address.length < 5) return 'Enter the delivery address.';
  if (address.length > 300) return 'Use at most 300 characters.';
  return null;
}

/// Immutable agreed terms, independent of future changes to a farmer offer.
class ProcurementOrder {
  const ProcurementOrder({
    required this.id,
    this.buyerId = 'demo-buyer',
    required this.createdAt,
    required this.productId,
    required this.productName,
    required this.offerId,
    required this.farmId,
    required this.farmName,
    required this.farmRegion,
    required this.quantityKg,
    required this.unitPrice,
    required this.delivery,
    required this.deliveryFee,
    required this.contactName,
    required this.phone,
    required this.address,
    required this.note,
    required this.status,
    this.confirmedAt,
    this.readyAt,
    this.completedAt,
    this.rejectedAt,
    this.cancelledAt,
    this.rejectionReason = '',
  });

  final String id;
  final String buyerId;
  final DateTime createdAt;
  final String productId;
  final String productName;
  final String offerId;
  final String farmId;
  final String farmName;
  final String farmRegion;
  final int quantityKg;
  final int unitPrice;
  final bool delivery;
  final int deliveryFee;
  final String contactName;
  final String phone;
  final String address;
  final String note;
  final OrderStatus status;
  final DateTime? confirmedAt;
  final DateTime? readyAt;
  final DateTime? completedAt;
  final DateTime? rejectedAt;
  final DateTime? cancelledAt;
  final String rejectionReason;

  int get subtotal => quantityKg * unitPrice;
  int get total => subtotal + deliveryFee;
  bool get canCancel => status == OrderStatus.pending;

  bool get isActive =>
      status == OrderStatus.pending ||
      status == OrderStatus.confirmed ||
      status == OrderStatus.ready;
  bool get canReject =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  ProcurementOrder cancelled(DateTime at) =>
      _withStatus(OrderStatus.cancelled, at: at);
  ProcurementOrder markedReady(DateTime at) =>
      _withStatus(OrderStatus.ready, at: at);
  ProcurementOrder completed(DateTime at) =>
      _withStatus(OrderStatus.completed, at: at);
  ProcurementOrder rejected(DateTime at, String reason) =>
      _withStatus(OrderStatus.rejected, at: at, reason: reason);
  ProcurementOrder confirmed(DateTime at) =>
      _withStatus(OrderStatus.confirmed, at: at);

  ProcurementOrder _withStatus(
    OrderStatus next, {
    DateTime? at,
    String? reason,
  }) => ProcurementOrder(
    id: id,
    buyerId: buyerId,
    createdAt: createdAt,
    productId: productId,
    productName: productName,
    offerId: offerId,
    farmId: farmId,
    farmName: farmName,
    farmRegion: farmRegion,
    quantityKg: quantityKg,
    unitPrice: unitPrice,
    delivery: delivery,
    deliveryFee: deliveryFee,
    contactName: contactName,
    phone: phone,
    address: address,
    note: note,
    status: next,
    confirmedAt: next == OrderStatus.confirmed ? at : confirmedAt,
    readyAt: next == OrderStatus.ready ? at : readyAt,
    completedAt: next == OrderStatus.completed ? at : completedAt,
    rejectedAt: next == OrderStatus.rejected ? at : rejectedAt,
    cancelledAt: next == OrderStatus.cancelled ? at : cancelledAt,
    rejectionReason: reason ?? rejectionReason,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'buyerId': buyerId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'productId': productId,
    'productName': productName,
    'offerId': offerId,
    'farmId': farmId,
    'farmName': farmName,
    'farmRegion': farmRegion,
    'quantityKg': quantityKg,
    'unitPrice': unitPrice,
    'delivery': delivery,
    'deliveryFee': deliveryFee,
    'contactName': contactName,
    'phone': phone,
    'address': address,
    'note': note,
    'status': status.name,
    'confirmedAt': confirmedAt?.toUtc().toIso8601String(),
    'readyAt': readyAt?.toUtc().toIso8601String(),
    'completedAt': completedAt?.toUtc().toIso8601String(),
    'rejectedAt': rejectedAt?.toUtc().toIso8601String(),
    'cancelledAt': cancelledAt?.toUtc().toIso8601String(),
    'rejectionReason': rejectionReason,
  };

  factory ProcurementOrder.fromJson(Map<String, dynamic> json) {
    DateTime? date(String key) =>
        json[key] == null ? null : DateTime.parse(json[key] as String);
    final order = ProcurementOrder(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String? ?? 'demo-buyer',
      createdAt: DateTime.parse(json['createdAt'] as String),
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      offerId: json['offerId'] as String,
      farmId: json['farmId'] as String? ?? '',
      farmName: json['farmName'] as String,
      farmRegion: json['farmRegion'] as String,
      quantityKg: json['quantityKg'] as int,
      unitPrice: json['unitPrice'] as int,
      delivery: json['delivery'] as bool,
      deliveryFee: json['deliveryFee'] as int,
      contactName: json['contactName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      note: json['note'] as String,
      status: OrderStatus.values.byName(json['status'] as String),
      confirmedAt: date('confirmedAt'),
      readyAt: date('readyAt'),
      completedAt: date('completedAt'),
      rejectedAt: date('rejectedAt'),
      cancelledAt: date('cancelledAt'),
      rejectionReason: json['rejectionReason'] as String? ?? '',
    );
    if (order.id.isEmpty ||
        order.quantityKg <= 0 ||
        order.unitPrice <= 0 ||
        order.deliveryFee < 0 ||
        (!order.delivery && order.deliveryFee != 0) ||
        (order.status == OrderStatus.rejected &&
            (order.rejectedAt == null ||
                rejectionReasonError(order.rejectionReason) != null)) ||
        (order.status != OrderStatus.rejected &&
            order.rejectionReason.isNotEmpty)) {
      throw const FormatException('Invalid saved demo order.');
    }
    return order;
  }
}

String? rejectionReasonError(String? value) {
  final reason = value?.trim() ?? '';
  return reason.length < 5 || reason.length > 300
      ? 'Give a reason of 5–300 characters.'
      : null;
}

String orderDate(DateTime value) {
  final date = value.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class CheckoutSelection {
  const CheckoutSelection({required this.kg, required this.delivery});
  final int kg;
  final bool delivery;
}

String? availableQuantityError(FarmerOffer offer, int? kg, int remaining) {
  final error = offer.quantityError(kg);
  if (error != null) return error;
  if (kg! > remaining) return 'Only $remaining kg remains in this demo.';
  return null;
}
