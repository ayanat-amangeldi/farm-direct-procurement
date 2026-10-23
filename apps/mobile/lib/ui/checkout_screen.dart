import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../catalog/models.dart';
import '../orders/order.dart';
import '../orders/order_store.dart';
import 'order_confirmation_screen.dart';
import 'order_widgets.dart';
import 'shared.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    required this.product,
    required this.offer,
    required this.selection,
    super.key,
  });
  final Product product;
  final FarmerOffer offer;
  final CheckoutSelection selection;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _note = TextEditingController();
  late final TextEditingController _quantity = TextEditingController(
    text: '${widget.selection.kg}',
  );
  late bool _delivery = widget.selection.delivery;
  bool _submitting = false;
  final _quantityFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void dispose() {
    for (final controller in [_name, _phone, _address, _note, _quantity]) {
      controller.dispose();
    }
    for (final focus in [
      _quantityFocus,
      _addressFocus,
      _nameFocus,
      _phoneFocus,
    ]) {
      focus.dispose();
    }
    super.dispose();
  }

  Future<void> _place() async {
    if (_submitting) return;
    final store = OrderScope.of(context);
    if (!_form.currentState!.validate()) {
      if (availableQuantityError(
            widget.offer,
            int.tryParse(_quantity.text),
            store.availableKg(widget.offer),
          ) !=
          null) {
        _quantityFocus.requestFocus();
      } else if (_delivery && addressError(_address.text) != null) {
        _addressFocus.requestFocus();
      } else if (nameError(_name.text) != null) {
        _nameFocus.requestFocus();
      } else if (phoneError(_phone.text) != null) {
        _phoneFocus.requestFocus();
      }
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      final order = await store.place(
        product: widget.product,
        offer: widget.offer,
        kg: int.parse(_quantity.text),
        delivery: _delivery,
        contactName: _name.text,
        phone: _phone.text,
        address: _address.text,
        note: _note.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OrderConfirmationScreen(orderId: order.id),
        ),
      );
    } on OrderException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = OrderScope.of(context);
    final offer = widget.offer;
    final remaining = store.availableKg(offer);
    final kg = int.tryParse(_quantity.text);
    final quantityError = availableQuantityError(offer, kg, remaining);
    final quote = quantityError == null
        ? offer.quote(kg: kg!, delivery: _delivery)
        : null;
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Checkout',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
                    const Text(
                      'Complete your order',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use sample contact details. This creates a demo order only; no payment is collected.',
                      style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 22),
                    OrderProductSummary(
                      productId: widget.product.id,
                      productName: widget.product.name,
                      farmName: offer.farmName,
                    ),
                    OrderSection(
                      title: 'Quantity and fulfillment',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            key: const Key('checkout-quantity'),
                            focusNode: _quantityFocus,
                            enabled: !_submitting,
                            controller: _quantity,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (_) => setState(() {}),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) => availableQuantityError(
                              offer,
                              int.tryParse(value ?? ''),
                              store.availableKg(offer),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Quantity (kg)',
                              helperText:
                                  'Minimum ${offer.minimumKg} kg · $remaining kg available',
                              suffixText: 'kg',
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('Pickup · free'),
                                selected: !_delivery,
                                onSelected: _submitting
                                    ? null
                                    : (_) => setState(() => _delivery = false),
                              ),
                              if (offer.deliveryFee != null)
                                ChoiceChip(
                                  label: Text(
                                    'Delivery · ${money(offer.deliveryFee!)}',
                                  ),
                                  selected: _delivery,
                                  onSelected: _submitting
                                      ? null
                                      : (_) => setState(() => _delivery = true),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_delivery)
                            TextFormField(
                              key: const Key('checkout-address'),
                              focusNode: _addressFocus,
                              enabled: !_submitting,
                              controller: _address,
                              minLines: 2,
                              maxLines: 3,
                              maxLength: 300,
                              validator: addressError,
                              decoration: const InputDecoration(
                                labelText: 'Delivery address',
                                hintText: 'City, street, building and unit',
                              ),
                            )
                          else
                            Text(
                              'Pickup region: ${offer.location}. Exact collection details will be agreed with the farmer.',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                    OrderSection(
                      title: 'Contact details',
                      child: Column(
                        children: [
                          TextFormField(
                            key: const Key('checkout-name'),
                            focusNode: _nameFocus,
                            enabled: !_submitting,
                            controller: _name,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 80,
                            validator: nameError,
                            decoration: const InputDecoration(
                              labelText: 'Contact name',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('checkout-phone'),
                            focusNode: _phoneFocus,
                            enabled: !_submitting,
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            maxLength: 30,
                            validator: phoneError,
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                              hintText: '+7 7XX XXX XX XX',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('checkout-note'),
                            controller: _note,
                            minLines: 2,
                            maxLines: 4,
                            maxLength: 500,
                            decoration: const InputDecoration(
                              labelText: 'Note for the farmer (optional)',
                            ),
                          ),
                        ],
                      ),
                    ),
                    OrderSection(
                      title: 'Agreed price',
                      child: quote == null
                          ? const Text(
                              'Enter a valid quantity to calculate the total.',
                              style: TextStyle(color: muted),
                            )
                          : OrderPriceBreakdown(
                              kg: kg!,
                              unitPrice: offer.pricePerKg,
                              delivery: _delivery,
                              deliveryFee: quote.delivery,
                              totalKey: const Key('checkout-total'),
                            ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'The accepted price and delivery fee are saved with your order. Later offer changes will not change these terms.',
                      style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const Key('place-order'),
                      onPressed: _submitting || quote == null ? null : _place,
                      child: Text(
                        _submitting ? 'Saving order…' : 'Place demo order',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      store.sessionOnly
                          ? 'Demo orders are kept for this session only.'
                          : 'Demo orders are saved on this device only.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: muted, fontSize: 11),
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
}
