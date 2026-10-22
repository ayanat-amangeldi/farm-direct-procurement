import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../catalog/models.dart';
import 'shared.dart';

class PricePreview extends StatefulWidget {
  const PricePreview({required this.product, required this.offer, super.key});
  final Product product;
  final FarmerOffer offer;
  @override
  State<PricePreview> createState() => _PricePreviewState();
}

class _PricePreviewState extends State<PricePreview> {
  late final TextEditingController _quantity;
  bool _delivery = false;

  @override
  void initState() {
    super.initState();
    _quantity = TextEditingController(text: '${widget.offer.minimumKg}');
  }

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final kg = int.tryParse(_quantity.text);
    final error = offer.quantityError(kg);
    final quote = error == null
        ? offer.quote(kg: kg!, delivery: _delivery)
        : null;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: lineColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Your price, explained',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close price preview',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Text(
            '${widget.product.name} · ${offer.farmName}',
            style: const TextStyle(color: muted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          TextField(
            key: const Key('offer-quantity'),
            controller: _quantity,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Quantity (kg)',
              helperText:
                  'Minimum ${offer.minimumKg} kg · available ${offer.availableKg} kg',
              errorText: error,
              suffixText: 'kg',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'How will you receive it?',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Pickup · free'),
                selected: !_delivery,
                onSelected: (_) => setState(() => _delivery = false),
              ),
              if (offer.deliveryFee != null)
                ChoiceChip(
                  label: Text('Delivery · ${money(offer.deliveryFee!)}'),
                  selected: _delivery,
                  onSelected: (_) => setState(() => _delivery = true),
                ),
            ],
          ),
          if (offer.deliveryFee == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'This farmer currently offers pickup only.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: canvasColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: quote == null
                ? const Text(
                    'Enter a valid quantity to see your total.',
                    style: TextStyle(color: muted),
                  )
                : Column(
                    children: [
                      _line(
                        '$kg kg × ${money(offer.pricePerKg)}',
                        money(quote.productSubtotal),
                      ),
                      const SizedBox(height: 12),
                      _line(
                        _delivery ? 'Delivery' : 'Pickup',
                        quote.delivery == 0 ? 'Free' : money(quote.delivery),
                      ),
                      const SizedBox(height: 12),
                      _line('Other fees', money(0)),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, color: lineColor),
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            money(quote.total),
                            key: const Key('quote-total'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: forest,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Demo price preview. No order is placed.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to offers'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(color: muted, fontSize: 14)),
      ),
      const SizedBox(width: 10),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}
