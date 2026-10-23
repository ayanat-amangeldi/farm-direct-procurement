import 'package:flutter/material.dart';
import '../catalog/models.dart';
import '../orders/order.dart';
import '../orders/order_store.dart';
import 'shared.dart';

class FarmerOrderActions extends StatefulWidget {
  const FarmerOrderActions({
    required this.order,
    required this.farmId,
    super.key,
  });
  final ProcurementOrder order;
  final String farmId;
  @override
  State<FarmerOrderActions> createState() => _FarmerOrderActionsState();
}

class _FarmerOrderActionsState extends State<FarmerOrderActions> {
  bool _saving = false;
  String _reasonDraft = '';

  Future<void> _save(Future<void> Function() action) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order status updated for the buyer on this device.'),
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
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _advance(OrderStatus target) async {
    final store = OrderScope.of(context);
    final order = widget.order;
    final (title, message, button) = switch (target) {
      OrderStatus.confirmed => (
        'Confirm this demo order?',
        'Accept ${order.quantityKg} kg of ${order.productName.toLowerCase()} for ${money(order.total)}, including ${order.delivery ? 'delivery' : 'pickup'}. The saved price stays fixed.',
        'Confirm order',
      ),
      OrderStatus.ready => (
        'Mark this order ready?',
        order.delivery
            ? 'Confirm that this order is packed and ready for delivery.'
            : 'Confirm that this order is packed and ready for the buyer to collect.',
        'Mark ready',
      ),
      OrderStatus.completed => (
        'Complete this demo order?',
        order.delivery
            ? 'Confirm that delivery to the buyer has been completed.'
            : 'Confirm that the buyer has collected this order.',
        'Complete order',
      ),
      _ => throw StateError('Unsupported action'),
    };
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(button),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    await _save(
      () => switch (target) {
        OrderStatus.confirmed => store.confirm(order.id, farmId: widget.farmId),
        OrderStatus.ready => store.markReady(order.id, farmId: widget.farmId),
        OrderStatus.completed => store.complete(
          order.id,
          farmId: widget.farmId,
        ),
        _ => throw StateError('Unsupported action'),
      },
    );
  }

  Future<void> _reject() async {
    final store = OrderScope.of(context);
    final form = GlobalKey<FormState>();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Reject this demo order?'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explain why you cannot fulfill the order. The buyer will see this reason and the quantity will become available again.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('rejection-reason'),
                initialValue: _reasonDraft,
                maxLength: 300,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Reason for rejection',
                ),
                validator: rejectionReasonError,
                onChanged: (value) => _reasonDraft = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, _reasonDraft.trim());
              }
            },
            child: const Text('Reject order'),
          ),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    await _save(
      () =>
          store.reject(widget.order.id, farmId: widget.farmId, reason: reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final next = switch (order.status) {
      OrderStatus.pending => OrderStatus.confirmed,
      OrderStatus.confirmed => OrderStatus.ready,
      OrderStatus.ready => OrderStatus.completed,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (next != null) ...[
          const SizedBox(height: 22),
          FilledButton.icon(
            key: Key(switch (next) {
              OrderStatus.confirmed => 'confirm-farmer-order',
              OrderStatus.ready => 'ready-farmer-order',
              _ => 'complete-farmer-order',
            }),
            onPressed: _saving ? null : () => _advance(next),
            icon: const Icon(Icons.check, size: 18),
            label: Text(
              _saving
                  ? 'Saving…'
                  : switch (next) {
                      OrderStatus.confirmed => 'Confirm demo order',
                      OrderStatus.ready =>
                        order.delivery
                            ? 'Mark ready for delivery'
                            : 'Mark ready for pickup',
                      _ => 'Mark completed',
                    },
            ),
          ),
        ],
        if (order.canReject) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('reject-farmer-order'),
            onPressed: _saving ? null : _reject,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Reject order'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9D3F35),
            ),
          ),
        ],
        if (next != null || order.canReject) ...[
          const SizedBox(height: 10),
          const Text(
            'Status changes appear in the buyer’s history. Saved price, quantity and delivery terms stay fixed.',
            style: TextStyle(fontSize: 12, color: muted, height: 1.5),
          ),
        ],
      ],
    );
  }
}
