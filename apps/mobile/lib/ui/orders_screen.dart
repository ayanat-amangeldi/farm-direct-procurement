import 'package:flutter/material.dart';
import '../catalog/models.dart';
import '../orders/order.dart';
import '../orders/order_store.dart';
import 'order_details_screen.dart';
import 'order_widgets.dart';
import 'shared.dart';

enum OrdersFilter { all, active, completed, cancelled }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrdersFilter _filter = OrdersFilter.all;
  bool _matches(ProcurementOrder order) => switch (_filter) {
    OrdersFilter.all => true,
    OrdersFilter.active =>
      order.status != OrderStatus.completed &&
          order.status != OrderStatus.cancelled,
    OrdersFilter.completed => order.status == OrderStatus.completed,
    OrdersFilter.cancelled => order.status == OrderStatus.cancelled,
  };

  @override
  Widget build(BuildContext context) {
    final store = OrderScope.of(context);
    final orders = store.orders.where(_matches).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My orders',
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
              const Text(
                'Your procurement orders',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                store.sessionOnly
                    ? 'Demo orders · this session only'
                    : 'Demo orders · saved on this device',
                style: const TextStyle(color: muted, fontSize: 13),
              ),
              if (store.loadFailed)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Previous history could not be loaded. It has not been overwritten. New orders are available for this session only.',
                    style: TextStyle(color: muted, height: 1.5),
                  ),
                ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('All', OrdersFilter.all),
                    _chip('Active', OrdersFilter.active),
                    _chip('Completed', OrdersFilter.completed),
                    _chip('Cancelled', OrdersFilter.cancelled),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (orders.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: muted,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        store.orders.isEmpty
                            ? 'No orders yet'
                            : 'No orders in this category',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Choose a product and farmer offer to create a demo procurement order.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      if (store.orders.isNotEmpty)
                        OutlinedButton(
                          onPressed: () =>
                              setState(() => _filter = OrdersFilter.all),
                          child: const Text('Show all orders'),
                        ),
                      FilledButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                        child: const Text('Browse products'),
                      ),
                    ],
                  ),
                )
              else
                for (final order in orders)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: lineColor),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: Key('order-${order.id}'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                OrderDetailsScreen(orderId: order.id),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 14,
                                runSpacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    order.id,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  OrderStatusBadge(order.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                orderDate(order.createdAt),
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 18),
                              OrderProductSummary(
                                productId: order.productId,
                                productName: order.productName,
                                farmName: order.farmName,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '${order.quantityKg} kg · ${order.delivery ? 'Delivery' : 'Pickup'}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: muted,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(height: 1, color: lineColor),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      money(order.total),
                                      style: const TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w700,
                                        color: forest,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'View details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: forest,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 17,
                                    color: forest,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, OrdersFilter filter) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _filter == filter,
      showCheckmark: false,
      selectedColor: ink,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: _filter == filter ? Colors.white : muted,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (_) => setState(() => _filter = filter),
    ),
  );
}
