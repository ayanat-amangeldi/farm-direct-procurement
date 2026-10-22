import 'package:flutter/material.dart';

import '../catalog/demo_catalog.dart';
import '../catalog/models.dart';
import 'price_preview.dart';
import 'produce_art.dart';
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

  @override
  Widget build(BuildContext context) {
    final offers = const DemoCatalog()
        .offersFor(widget.product.id)
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
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ProduceArt.background(widget.product.id),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STRAIGHT FROM THE GROWER',
                              style: TextStyle(
                                color: muted,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 29,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.product.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: ProduceArt(widget.product.id),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const DemoLabel(),
              const SizedBox(height: 20),
              const Text(
                'Choose your farmer',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Compare unit prices and delivery terms.\nYour full total is shown in the price preview.',
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
                          const Icon(
                            Icons.sort_rounded,
                            size: 18,
                            color: muted,
                          ),
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
                  title: 'No delivery offers yet',
                  message: 'This product currently has pickup offers only.',
                  onReset: () => setState(() => _deliveryOnly = false),
                )
              else
                for (final offer in offers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _OfferCard(
                      offer: offer,
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Colors.white,
                        constraints: const BoxConstraints(maxWidth: 680),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        builder: (_) =>
                            PricePreview(product: widget.product, offer: offer),
                      ),
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
  const _OfferCard({required this.offer, required this.onTap});
  final FarmerOffer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    key: Key('offer-${offer.id}'),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: lineColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2E7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.agriculture_outlined,
                size: 24,
                color: forest,
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
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Fact(Icons.location_on_outlined, offer.location),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: money(offer.pricePerKg),
                style: const TextStyle(
                  color: forest,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const TextSpan(
                text: ' / kg',
                style: TextStyle(color: muted, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            Fact(
              Icons.inventory_2_outlined,
              '${offer.availableKg} kg available',
            ),
            Fact(Icons.shopping_bag_outlined, 'Min. ${offer.minimumKg} kg'),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(height: 1, color: lineColor),
        ),
        Fact(
          Icons.local_shipping_outlined,
          offer.deliveryFee == null
              ? 'Pickup only · no delivery fee'
              : 'Pickup free · delivery ${money(offer.deliveryFee!)}',
        ),
        const SizedBox(height: 16),
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
                Icon(Icons.arrow_forward, size: 17),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
