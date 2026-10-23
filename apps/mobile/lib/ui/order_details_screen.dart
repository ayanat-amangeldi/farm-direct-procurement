import 'package:flutter/material.dart';
import '../catalog/models.dart';
import '../orders/order.dart';
import '../orders/order_store.dart';
import 'order_widgets.dart';
import 'shared.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({required this.orderId, this.farmId, super.key});
  final String orderId;
  final String? farmId;
  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _cancelling = false;
  bool _confirming = false;

  Future<void> _confirm() async {
    if (_confirming) return;
    final store = OrderScope.of(context);
    final order = store.find(widget.orderId);
    if (order == null || order.farmId != widget.farmId) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm this demo order?'),
        content: Text(
          'Accept ${order.quantityKg} kg of ${order.productName.toLowerCase()} for ${money(order.total)}, including ${order.delivery ? 'delivery' : 'pickup'}. The saved price stays fixed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm order'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() => _confirming = true);
    try {
      await store.confirm(widget.orderId, farmId: widget.farmId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Order confirmed. Buyer status updated on this device.',
            ),
          ),
        );
      }
    } on OrderException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _cancel() async {
    final store = OrderScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this demo order?'),
        content: const Text(
          'The saved price remains in your history. The quantity will become available again in this demo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _cancelling = true);
    try {
      await store.cancel(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Demo order cancelled.')));
      }
    } on OrderException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidate = OrderScope.of(context).find(widget.orderId);
    final farmerView = widget.farmId != null;
    final order =
        farmerView &&
            (widget.farmId!.isEmpty || candidate?.farmId != widget.farmId)
        ? null
        : candidate;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          order?.id ?? 'Order details',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: order == null
          ? const Center(child: Text('Order not available in this view.'))
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    Text(
                      farmerView ? 'Incoming order' : 'Order details',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      orderDate(order.createdAt),
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OrderStatusBadge(order.status),
                    ),
                    if (order.confirmedAt != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Confirmed ${orderDate(order.confirmedAt!)}',
                        key: const Key('order-confirmed-at'),
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                    const SizedBox(height: 24),
                    OrderProductSummary(
                      productId: order.productId,
                      productName: order.productName,
                      farmName: order.farmName,
                    ),
                    OrderSection(
                      title: 'Saved order price',
                      child: OrderPriceBreakdown(
                        kg: order.quantityKg,
                        unitPrice: order.unitPrice,
                        delivery: order.delivery,
                        deliveryFee: order.deliveryFee,
                        totalKey: const Key('saved-order-total'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This price was fixed when the demo order was created.',
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                    OrderSection(
                      title: 'Contact and fulfillment',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: lineColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.contactName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order.phone,
                              style: const TextStyle(color: muted),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              order.delivery
                                  ? 'Delivery address'
                                  : 'Pickup region',
                              style: const TextStyle(
                                fontSize: 12,
                                color: muted,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              order.delivery ? order.address : order.farmRegion,
                              style: const TextStyle(height: 1.5),
                            ),
                            if (!order.delivery)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Agree the exact collection details with the farmer.',
                                  style: TextStyle(fontSize: 12, color: muted),
                                ),
                              ),
                            if (order.note.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Note for the farmer',
                                style: TextStyle(fontSize: 12, color: muted),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                order.note,
                                style: const TextStyle(height: 1.5),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    OrderSection(
                      title: 'Order progress',
                      child: _OrderProgress(order),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Local demonstration only. No farmer has been contacted and no payment has been processed.',
                      style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                    ),
                    if (farmerView && order.status == OrderStatus.pending) ...[
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        key: const Key('confirm-farmer-order'),
                        onPressed: _confirming ? null : _confirm,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(
                          _confirming ? 'Saving…' : 'Confirm demo order',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Confirmation updates the buyer’s status here. Price, quantity and delivery terms cannot be edited.',
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                          height: 1.5,
                        ),
                      ),
                    ],
                    if (!farmerView && order.canCancel) ...[
                      const SizedBox(height: 22),
                      OutlinedButton(
                        key: const Key('cancel-order'),
                        onPressed: _cancelling ? null : _cancel,
                        child: Text(
                          _cancelling ? 'Saving…' : 'Cancel demo order',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _OrderProgress extends StatelessWidget {
  const _OrderProgress(this.order);
  final ProcurementOrder order;
  @override
  Widget build(BuildContext context) {
    final steps = order.status == OrderStatus.cancelled
        ? ['Order created', 'Order cancelled']
        : [
            'Order created',
            'Farmer confirmation',
            order.delivery ? 'Ready for delivery' : 'Ready for pickup',
            'Completed',
          ];
    final completedThrough = switch (order.status) {
      OrderStatus.pending => 0,
      OrderStatus.confirmed => 1,
      OrderStatus.ready => 2,
      OrderStatus.completed => 3,
      OrderStatus.cancelled => 1,
    };
    final current = completedThrough < steps.length - 1
        ? completedThrough + 1
        : completedThrough;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  i <= completedThrough
                      ? Icons.check_circle
                      : i == current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: i <= current ? forest : lineColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 13,
                      color: i <= current ? ink : muted,
                      fontWeight: i == current
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (i == 1 && order.status == OrderStatus.pending)
                  const Text(
                    'Pending',
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
