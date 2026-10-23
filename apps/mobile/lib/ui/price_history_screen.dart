import 'package:flutter/material.dart';
import '../catalog/models.dart';
import '../catalog/price_change.dart';
import '../orders/order.dart';
import '../orders/order_store.dart';
import 'order_widgets.dart';
import 'shared.dart';

class PriceHistoryScreen extends StatelessWidget {
  const PriceHistoryScreen({required this.offerId, this.farmId, super.key});
  final String offerId;
  final String? farmId;
  @override
  Widget build(BuildContext context) {
    final store = OrderScope.of(context);
    final candidate = store.offer(offerId);
    final offer = farmId != null && candidate?.farmId != farmId
        ? null
        : candidate;
    final history = store.priceHistoryFor(offerId);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Price history',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: offer == null
          ? const Center(child: Text('Offer not available in this view.'))
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    const Text(
                      'How the price changed',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 18),
                    OrderProductSummary(
                      productId: offer.productId,
                      productName:
                          store.product(offer.productId)?.name ?? 'Product',
                      farmName: offer.farmName,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: ink,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT UNIT PRICE',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.3,
                              color: Color(0xFFBED2C9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${money(offer.pricePerKg)} / kg',
                            key: const Key('history-current-price'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Delivery: ${deliveryTerm(offer.deliveryFee)}',
                            style: const TextStyle(
                              color: Color(0xFFBED2C9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Existing orders keep their accepted price and delivery fee. Dates use this device’s time zone.',
                      style: TextStyle(fontSize: 12, color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    if (history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No recorded price changes yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      for (final change in history) _PriceChangeCard(change),
                    const SizedBox(height: 14),
                    const Text(
                      'This local history contains changes recorded by this version of the prototype. Earlier changes were not tracked.',
                      style: TextStyle(fontSize: 12, color: muted, height: 1.5),
                    ),
                    if (store.sessionOnly)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'History is kept for this demo session only.',
                          style: TextStyle(fontSize: 12, color: muted),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

String deliveryTerm(int? fee) => fee == null
    ? 'Pickup only'
    : fee == 0
    ? 'Free delivery'
    : money(fee);

class _PriceChangeCard extends StatelessWidget {
  const _PriceChangeCard(this.change);
  final PriceChange change;
  @override
  Widget build(BuildContext context) {
    final at = change.at.toLocal();
    final delta = change.newPrice - (change.oldPrice ?? change.newPrice);
    return Container(
      key: Key('price-change-${change.id}'),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: lineColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            change.published
                ? 'Offer published'
                : change.unitChanged && change.deliveryChanged
                ? 'Price and delivery updated'
                : change.unitChanged
                ? 'Unit price updated'
                : 'Delivery updated',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${orderDate(at)}:${at.second.toString().padLeft(2, '0')}',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (change.published || change.unitChanged) ...[
            Text(
              change.published
                  ? 'Initial price: ${money(change.newPrice)} / kg'
                  : '${money(change.oldPrice!)} → ${money(change.newPrice)} / kg',
              style: const TextStyle(
                fontSize: 20,
                color: forest,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!change.published)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${delta > 0 ? 'Increase' : 'Decrease'}: ${money(delta.abs())} / kg',
                  style: const TextStyle(fontSize: 12, color: muted),
                ),
              ),
          ],
          if (change.published || change.deliveryChanged) ...[
            const SizedBox(height: 12),
            Text(
              change.published
                  ? 'Delivery: ${deliveryTerm(change.newDeliveryFee)}'
                  : 'Delivery: ${deliveryTerm(change.oldDeliveryFee)} → ${deliveryTerm(change.newDeliveryFee)}',
              style: const TextStyle(fontSize: 13, color: muted, height: 1.5),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            'Saved by this offer’s demo farmer',
            style: TextStyle(fontSize: 11, color: muted),
          ),
        ],
      ),
    );
  }
}
