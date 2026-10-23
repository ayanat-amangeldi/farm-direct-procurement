import 'package:flutter/material.dart';

import '../catalog/demo_catalog.dart';
import '../catalog/models.dart';
import '../orders/order.dart';
import '../orders/order_store.dart';
import 'checkout_screen.dart';
import 'price_preview.dart';
import 'product_photo.dart';
import 'shared.dart';

enum OfferSort { price, farm }

class OffersScreen extends StatefulWidget {
  const OffersScreen({required this.product, super.key});
  final Product product;
  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  bool _deliveryOnly = false;
  OfferSort _sort = OfferSort.price;

  Future<void> _openOffer(FarmerOffer offer) async {
    final selection = await showModalBottomSheet<CheckoutSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 680),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PricePreview(product: widget.product, offer: offer),
    );
    if (selection == null || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(
          product: widget.product,
          offer: offer,
          selection: selection,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = OrderScope.of(context);
    final available = const DemoCatalog()
        .offersFor(widget.product.id)
        .where((offer) => store.availableKg(offer) >= offer.minimumKg)
        .toList();
    final offers = available
        .where((offer) => !_deliveryOnly || offer.deliveryFee != null)
        .toList();
    offers.sort(
      (a, b) => _sort == OfferSort.price
          ? a.pricePerKg.compareTo(b.pricePerKg)
          : a.farmName.compareTo(b.farmName),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Farmer offers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ProductPhoto(widget.product.id),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.product.description,
                style: const TextStyle(fontSize: 14, color: muted),
              ),
              const SizedBox(height: 14),
              const DemoLabel(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Divider(height: 1, color: lineColor),
              ),
              const Text(
                'Compare farmer offers',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unit prices, minimum quantities and delivery costs are shown separately.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilterChip(
                    label: const Text('Delivery available'),
                    selected: _deliveryOnly,
                    onSelected: (value) =>
                        setState(() => _deliveryOnly = value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    avatar: const Icon(Icons.local_shipping_outlined, size: 17),
                  ),
                  PopupMenuButton<OfferSort>(
                    tooltip: 'Sort farmer offers',
                    initialValue: _sort,
                    onSelected: (value) => setState(() => _sort = value),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: OfferSort.price,
                        child: Text('Lowest unit price'),
                      ),
                      PopupMenuItem(
                        value: OfferSort.farm,
                        child: Text('Farm name'),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort, size: 17, color: muted),
                          const SizedBox(width: 5),
                          Text(
                            _sort == OfferSort.price
                                ? 'Lowest unit price'
                                : 'Farm name',
                            style: const TextStyle(fontSize: 12, color: muted),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 17,
                            color: muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '${offers.length} ${offers.length == 1 ? 'offer' : 'offers'} available',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              if (offers.isEmpty)
                EmptyResults(
                  title: available.isEmpty
                      ? 'No available offers'
                      : 'No delivery offers yet',
                  message: available.isEmpty
                      ? 'No farmer has the minimum quantity available in this demo.'
                      : 'This product currently has pickup offers only.',
                  onReset: available.isEmpty
                      ? () => Navigator.pop(context)
                      : () => setState(() => _deliveryOnly = false),
                  resetLabel: available.isEmpty
                      ? 'Back to catalog'
                      : 'Reset filters',
                )
              else
                for (final offer in offers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _OfferCard(
                      offer: offer,
                      availableKg: store.availableKg(offer),
                      onTap: () => _openOffer(offer),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.availableKg,
    required this.onTap,
  });
  final FarmerOffer offer;
  final int availableKg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    key: Key('offer-${offer.id}'),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: lineColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F3F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                offer.farmName.substring(0, 1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: forest,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.farmName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Fact(Icons.location_on_outlined, offer.location),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: money(offer.pricePerKg),
                style: const TextStyle(
                  color: ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const TextSpan(
                text: ' / kg',
                style: TextStyle(color: muted, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 18,
          runSpacing: 10,
          children: [
            Fact(Icons.inventory_2_outlined, '$availableKg kg available'),
            Fact(Icons.shopping_bag_outlined, 'Min. ${offer.minimumKg} kg'),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1, color: lineColor),
        ),
        Fact(
          Icons.local_shipping_outlined,
          offer.deliveryFee == null
              ? 'Pickup only · no delivery fee'
              : 'Pickup free · delivery ${money(offer.deliveryFee!)}',
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: Key('view-${offer.id}'),
            onPressed: onTap,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('View offer'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
