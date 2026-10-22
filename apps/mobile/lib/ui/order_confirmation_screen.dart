import 'package:flutter/material.dart';
import '../catalog/models.dart';
import '../orders/order_store.dart';
import 'order_details_screen.dart';
import 'orders_screen.dart';
import 'order_widgets.dart';
import 'shared.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({required this.orderId, super.key});
  final String orderId;
  @override
  Widget build(BuildContext context) {
    final order = OrderScope.of(context).find(orderId);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Order confirmation',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: order == null
          ? const Center(child: Text('Order not found on this device.'))
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.check_circle, color: forest, size: 54),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Demo order created',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your order number is ${order.id}.',
                      key: const Key('confirmation-number'),
                      style: const TextStyle(color: muted, fontSize: 15),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OrderStatusBadge(order.status),
                    ),
                    const SizedBox(height: 24),
                    OrderProductSummary(
                      productId: order.productId,
                      productName: order.productName,
                      farmName: order.farmName,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${order.quantityKg} kg · ${order.delivery ? 'Delivery' : 'Pickup'}',
                      style: const TextStyle(color: muted, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Agreed total ${money(order.total)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: forest,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'The order is waiting for farmer confirmation in the prototype. No payment was taken and no real farmer was notified.',
                      style: TextStyle(color: muted, fontSize: 13, height: 1.6),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => OrderDetailsScreen(orderId: orderId),
                        ),
                      ),
                      child: const Text('View order details'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const OrdersScreen(),
                        ),
                        (route) => route.isFirst,
                      ),
                      child: const Text('View all orders'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                      child: const Text('Continue browsing'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
