/// An append-only record of a successful local publication or price/fee change.
class PriceChange {
  const PriceChange({
    required this.id,
    required this.offerId,
    required this.farmId,
    required this.at,
    required this.oldPrice,
    required this.newPrice,
    required this.oldDeliveryFee,
    required this.newDeliveryFee,
  });
  final String id;
  final String offerId;
  final String farmId;
  final DateTime at;
  final int? oldPrice;
  final int newPrice;
  final int? oldDeliveryFee;
  final int? newDeliveryFee;
  bool get published => oldPrice == null;
  bool get unitChanged => oldPrice != newPrice;
  bool get deliveryChanged => oldDeliveryFee != newDeliveryFee;

  Map<String, Object?> toJson() => {
    'id': id,
    'offerId': offerId,
    'farmId': farmId,
    'at': at.toUtc().toIso8601String(),
    'oldPrice': oldPrice,
    'newPrice': newPrice,
    'oldDeliveryFee': oldDeliveryFee,
    'newDeliveryFee': newDeliveryFee,
  };
  factory PriceChange.fromJson(Map<String, dynamic> json) {
    final change = PriceChange(
      id: json['id'] as String,
      offerId: json['offerId'] as String,
      farmId: json['farmId'] as String,
      at: DateTime.parse(json['at'] as String),
      oldPrice: json['oldPrice'] as int?,
      newPrice: json['newPrice'] as int,
      oldDeliveryFee: json['oldDeliveryFee'] as int?,
      newDeliveryFee: json['newDeliveryFee'] as int?,
    );
    if (change.id.isEmpty ||
        change.offerId.isEmpty ||
        change.farmId.isEmpty ||
        change.newPrice <= 0 ||
        change.newPrice > 10000000 ||
        (change.oldPrice != null &&
            (change.oldPrice! <= 0 || change.oldPrice! > 10000000)) ||
        [
          change.oldDeliveryFee,
          change.newDeliveryFee,
        ].any((fee) => fee != null && (fee < 0 || fee > 10000000)) ||
        (!change.unitChanged && !change.deliveryChanged)) {
      throw const FormatException('Invalid saved price history.');
    }
    return change;
  }
}
