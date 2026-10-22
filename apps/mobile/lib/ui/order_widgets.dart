import 'package:flutter/material.dart';
import '../catalog/models.dart';
import '../orders/order.dart';
import 'product_photo.dart';
import 'shared.dart';

class OrderProductSummary extends StatelessWidget {
  const OrderProductSummary({
    required this.productId,
    required this.productName,
    required this.farmName,
    super.key,
  });
  final String productId;
  final String productName;
  final String farmName;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 72, height: 72, child: ProductPhoto(productId)),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(farmName, style: const TextStyle(fontSize: 13, color: muted)),
          ],
        ),
      ),
    ],
  );
}

class OrderPriceBreakdown extends StatelessWidget {
  const OrderPriceBreakdown({
    required this.kg,
    required this.unitPrice,
    required this.delivery,
    required this.deliveryFee,
    this.totalKey,
    super.key,
  });
  final int kg;
  final int unitPrice;
  final bool delivery;
  final int deliveryFee;
  final Key? totalKey;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: lineColor),
    ),
    child: Column(
      children: [
        _line('Products · $kg kg × ${money(unitPrice)}', money(kg * unitPrice)),
        const SizedBox(height: 12),
        _line(
          delivery ? 'Delivery' : 'Pickup',
          deliveryFee == 0 ? 'Free' : money(deliveryFee),
        ),
        const SizedBox(height: 12),
        _line('Other fees', money(0)),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1, color: lineColor),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'Total',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                money(kg * unitPrice + deliveryFee),
                key: totalKey,
                style: const TextStyle(
                  fontSize: 24,
                  color: forest,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _line(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(fontSize: 13, color: muted)),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge(this.status, {super.key});
  final OrderStatus status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: status == OrderStatus.pending
          ? const Color(0xFFFFF3D7)
          : status == OrderStatus.cancelled
          ? const Color(0xFFF0F1F2)
          : const Color(0xFFE6F2EA),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      status.label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: status == OrderStatus.pending
            ? const Color(0xFF866115)
            : status == OrderStatus.cancelled
            ? muted
            : forest,
      ),
    ),
  );
}

class OrderSection extends StatelessWidget {
  const OrderSection({required this.title, required this.child, super.key});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
