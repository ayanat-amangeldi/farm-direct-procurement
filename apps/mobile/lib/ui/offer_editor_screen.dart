import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../catalog/models.dart';
import '../catalog/offer_draft.dart';
import '../orders/order_store.dart';
import 'order_widgets.dart';
import 'shared.dart';

class OfferEditorScreen extends StatefulWidget {
  const OfferEditorScreen({required this.farm, this.offer, super.key});
  final FarmProfile farm;
  final FarmerOffer? offer;
  @override
  State<OfferEditorScreen> createState() => _OfferEditorScreenState();
}

class _OfferEditorScreenState extends State<OfferEditorScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _productDescription = TextEditingController();
  late final _price = TextEditingController(
    text: widget.offer?.pricePerKg.toString() ?? '',
  );
  late final _stock = TextEditingController(
    text: widget.offer?.availableKg.toString() ?? '',
  );
  late final _minimum = TextEditingController(
    text: widget.offer?.minimumKg.toString() ?? '',
  );
  late final _fee = TextEditingController(
    text: widget.offer?.deliveryFee?.toString() ?? '',
  );
  late final _region = TextEditingController(
    text: widget.offer?.location ?? widget.farm.region,
  );
  late final _description = TextEditingController(
    text: widget.offer?.description ?? '',
  );
  late String _productChoice = widget.offer?.productId ?? '__new__';
  ProductCategory _category = ProductCategory.vegetables;
  late bool _delivery = widget.offer?.deliveryFee != null;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _productDescription,
      _price,
      _stock,
      _minimum,
      _fee,
      _region,
      _description,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final invalid = _form.currentState!.validateGranularly();
    if (invalid.isNotEmpty) {
      await Scrollable.ensureVisible(
        invalid.first.context,
        duration: const Duration(milliseconds: 250),
        alignment: 0.15,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final store = OrderScope.of(context);
    setState(() => _saving = true);
    try {
      await store.saveOffer(
        farmId: widget.farm.id,
        offerId: widget.offer?.id,
        draft: OfferDraft(
          productId: _productChoice == '__new__' ? null : _productChoice,
          newProductName: _name.text,
          newProductCategory: _category,
          newProductDescription: _productDescription.text,
          pricePerKg: int.parse(_price.text),
          totalStockKg: int.parse(_stock.text),
          minimumKg: int.parse(_minimum.text),
          deliveryFee: _delivery ? int.parse(_fee.text) : null,
          location: _region.text,
          description: _description.text,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on OrderException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = OrderScope.of(context);
    final editing = widget.offer != null;
    final committed = editing ? store.reservedKg(widget.offer!.id) : 0;
    final stock = int.tryParse(_stock.text);
    final available = stock == null ? null : stock - committed;
    final listed = store
        .farmOffers(widget.farm.id)
        .map((offer) => offer.productId)
        .toSet();
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            editing ? 'Edit product' : 'Add product',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      editing ? 'Update your offer' : 'Publish a farm product',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.farm.name,
                      style: const TextStyle(
                        color: forest,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your price and terms appear in the buyer catalog. Demo changes are saved on this device only.',
                      style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                    ),
                    OrderSection(
                      title: 'Product',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (editing) ...[
                            Text(
                              store.product(_productChoice)?.name ??
                                  'Product unavailable',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'The product type stays fixed so buyers can compare offers for the same product.',
                              style: TextStyle(
                                fontSize: 12,
                                color: muted,
                                height: 1.5,
                              ),
                            ),
                          ] else ...[
                            DropdownButtonFormField<String>(
                              key: const Key('offer-product-type'),
                              initialValue: _productChoice,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Product type',
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: '__new__',
                                  child: Text('New product type…'),
                                ),
                                for (final product in store.products)
                                  DropdownMenuItem(
                                    value: product.id,
                                    enabled: !listed.contains(product.id),
                                    child: Text(
                                      '${product.name}${listed.contains(product.id) ? ' · already listed' : ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: _saving
                                  ? null
                                  : (id) {
                                      if (id != null) {
                                        setState(() => _productChoice = id);
                                      }
                                    },
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Choose an existing type to join its farmer offers. Types already listed by your farm can be edited from My products.',
                              style: TextStyle(
                                fontSize: 12,
                                color: muted,
                                height: 1.5,
                              ),
                            ),
                            if (_productChoice == '__new__') ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const Key('new-product-name'),
                                controller: _name,
                                enabled: !_saving,
                                maxLength: 60,
                                decoration: const InputDecoration(
                                  labelText: 'Product name',
                                  hintText: 'For example, Onions',
                                ),
                                validator: (value) {
                                  final name = value?.trim() ?? '';
                                  if (name.length < 2) {
                                    return 'Enter a product name of at least 2 characters.';
                                  }
                                  if (store.products.any(
                                    (item) =>
                                        item.name.toLowerCase() ==
                                        name.toLowerCase(),
                                  )) {
                                    return 'This type already exists. Select it above.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<ProductCategory>(
                                key: const Key('new-product-category'),
                                initialValue: _category,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                ),
                                items: [
                                  for (final category in ProductCategory.values)
                                    DropdownMenuItem(
                                      value: category,
                                      child: Text(categoryLabel(category)),
                                    ),
                                ],
                                onChanged: _saving
                                    ? null
                                    : (value) {
                                        if (value != null) {
                                          setState(() => _category = value);
                                        }
                                      },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const Key('new-product-description'),
                                controller: _productDescription,
                                enabled: !_saving,
                                maxLength: 160,
                                minLines: 2,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Product description (optional)',
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'New product types use a neutral image placeholder.',
                                style: TextStyle(fontSize: 12, color: muted),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                    OrderSection(
                      title: 'Price and stock',
                      child: Column(
                        children: [
                          _number(
                            'offer-price',
                            _price,
                            'Unit price (KZT / kg)',
                            max: 10000000,
                          ),
                          const SizedBox(height: 16),
                          _number(
                            'offer-stock',
                            _stock,
                            'Total stock (kg)',
                            allowZero: true,
                            helper: '$committed kg committed to saved orders',
                            extraValidator: (value) =>
                                int.parse(value!) < committed
                                ? 'Total stock cannot be below $committed committed kg.'
                                : null,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              available == null || available < 0
                                  ? 'Enter stock to calculate availability.'
                                  : '$available kg available to new buyers. Set total stock to 0 when no stock is committed to pause sales.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: muted,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _number(
                            'offer-minimum',
                            _minimum,
                            'Minimum order (kg)',
                            extraValidator: (value) =>
                                stock != null &&
                                    stock > 0 &&
                                    int.parse(value!) > stock
                                ? 'Minimum order cannot exceed total stock.'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    OrderSection(
                      title: 'Fulfillment and details',
                      child: Column(
                        children: [
                          TextFormField(
                            key: const Key('offer-region'),
                            controller: _region,
                            enabled: !_saving,
                            maxLength: 100,
                            decoration: const InputDecoration(
                              labelText: 'Pickup region',
                            ),
                            validator: (value) =>
                                (value?.trim().length ?? 0) < 2
                                ? 'Enter a pickup region.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            key: const Key('offer-delivery'),
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Offer delivery'),
                            subtitle: const Text('Pickup is always free'),
                            value: _delivery,
                            onChanged: _saving
                                ? null
                                : (value) => setState(() => _delivery = value),
                          ),
                          if (_delivery) ...[
                            const SizedBox(height: 12),
                            _number(
                              'offer-delivery-fee',
                              _fee,
                              'Delivery fee (KZT)',
                              allowZero: true,
                              max: 10000000,
                              helper:
                                  'One fee per order. Enter 0 for free delivery.',
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            key: const Key('offer-description'),
                            controller: _description,
                            enabled: !_saving,
                            maxLength: 500,
                            minLines: 3,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              labelText: 'Your product details (optional)',
                              hintText:
                                  'Variety, quality, packaging or harvest details',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Existing orders keep their saved price, quantity and delivery terms.',
                      style: TextStyle(fontSize: 12, color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const Key('save-farmer-offer'),
                      onPressed: _saving ? null : _save,
                      child: Text(
                        _saving
                            ? 'Saving…'
                            : editing
                            ? 'Save changes'
                            : 'Publish product',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _number(
    String key,
    TextEditingController controller,
    String label, {
    bool allowZero = false,
    int max = 1000000,
    String? helper,
    String? Function(String?)? extraValidator,
    ValueChanged<String>? onChanged,
  }) => TextFormField(
    key: Key(key),
    controller: controller,
    enabled: !_saving,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(
      labelText: label,
      helperText: helper,
      helperMaxLines: 3,
    ),
    validator: (value) =>
        wholeNumberError(value, allowZero: allowZero, max: max) ??
        extraValidator?.call(value),
    onChanged: onChanged,
  );
}
