import 'package:flutter/material.dart';
import '../catalog/models.dart';
import '../orders/order_store.dart';
import 'offer_editor_screen.dart';
import 'product_photo.dart';
import 'shared.dart';

class FarmerOffersScreen extends StatelessWidget {
  const FarmerOffersScreen({required this.farm, super.key});
  final FarmProfile farm;

  Future<void> _edit(BuildContext context, {FarmerOffer? offer}) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OfferEditorScreen(farm: farm, offer: offer),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            offer == null
                ? 'Product published in the buyer catalog.'
                : 'Product updated. Existing orders keep their agreed terms.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = OrderScope.of(context);
    final offers = store.farmOffers(farm.id);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My products',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text(
                farm.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${offers.length} ${offers.length == 1 ? 'product offer' : 'product offers'} · manage price, stock and delivery',
                style: const TextStyle(fontSize: 13, color: muted, height: 1.5),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const Key('add-farmer-product'),
                onPressed: () => _edit(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add product'),
              ),
              const SizedBox(height: 22),
              if (offers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No products listed yet. Add your first farm product.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, height: 1.5),
                  ),
                ),
              for (final offer in offers)
                Container(
                  key: Key('managed-offer-${offer.id}'),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: lineColor),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: ProductPhoto(offer.productId),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.product(offer.productId)?.name ??
                                      'Product',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${money(offer.pricePerKg)} / kg',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: forest,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${store.availableKg(offer)} kg available · minimum ${offer.minimumKg} kg',
                        style: const TextStyle(
                          fontSize: 13,
                          color: muted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${offer.availableKg} kg total · ${store.reservedKg(offer.id)} kg committed',
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        offer.deliveryFee == null
                            ? 'Pickup only · free'
                            : 'Pickup free · delivery ${money(offer.deliveryFee!)}',
                        style: const TextStyle(fontSize: 13, color: muted),
                      ),
                      if (store.availableKg(offer) < offer.minimumKg) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Unavailable to buyers: stock is below the minimum order.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF88601F),
                            height: 1.5,
                          ),
                        ),
                      ],
                      if (offer.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          offer.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: muted,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          key: Key('edit-offer-${offer.id}'),
                          onPressed: () => _edit(context, offer: offer),
                          icon: const Icon(Icons.edit_outlined, size: 17),
                          label: const Text('Edit product'),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              if (store.loadFailed)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Previous catalog or order history could not be loaded and has not been overwritten. Changes are session-only.',
                    style: TextStyle(fontSize: 12, color: muted, height: 1.5),
                  ),
                ),
              Text(
                store.sessionOnly
                    ? 'Demo changes are kept for this session only.'
                    : 'Demo changes are saved on this device only.',
                style: const TextStyle(fontSize: 12, color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
