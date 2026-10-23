import 'package:flutter/material.dart';
import 'account_bar.dart';
import '../orders/order.dart';
import '../orders/order_store.dart';
import 'order_details_screen.dart';
import 'farmer_offers_screen.dart';
import 'order_widgets.dart';
import 'shared.dart';

enum FarmerOrdersFilter { pending, confirmed, ready, completed, rejected, all }

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});
  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  FarmerOrdersFilter _filter = FarmerOrdersFilter.pending;

  @override
  Widget build(BuildContext context) {
    final store = OrderScope.of(context);
    final farm = store.currentFarm;
    if (farm == null) {
      return const Scaffold(
        body: Center(child: Text('Farmer account required.')),
      );
    }
    final farmId = farm.id;
    final all = store.ordersForFarm(farmId);
    final pending = all
        .where((order) => order.status == OrderStatus.pending)
        .length;
    final confirmed = all
        .where((order) => order.status == OrderStatus.confirmed)
        .length;
    final orders = all
        .where(
          (order) => switch (_filter) {
            FarmerOrdersFilter.pending => order.status == OrderStatus.pending,
            FarmerOrdersFilter.confirmed =>
              order.status == OrderStatus.confirmed,
            FarmerOrdersFilter.ready => order.status == OrderStatus.ready,
            FarmerOrdersFilter.completed =>
              order.status == OrderStatus.completed,
            FarmerOrdersFilter.rejected => order.status == OrderStatus.rejected,
            FarmerOrdersFilter.all => true,
          },
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Farmer workspace',
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
                'Incoming orders',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Manage orders for your farm. Only orders placed with your farm appear here.',
                style: TextStyle(fontSize: 13, color: muted, height: 1.5),
              ),
              const SizedBox(height: 22),
              const AccountBar(),
              Text(
                farm.name,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                farm.region,
                style: const TextStyle(fontSize: 12, color: muted),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                key: const Key('manage-farmer-products'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FarmerOffersScreen(farm: farm),
                  ),
                ),
                icon: const Icon(Icons.inventory_2_outlined, size: 18),
                label: Text(
                  'Manage products (${store.farmOffers(farmId).length})',
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ink,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Wrap(
                  spacing: 28,
                  runSpacing: 16,
                  children: [
                    _Metric('$pending', 'Awaiting confirmation'),
                    _Metric('$confirmed', 'Confirmed'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('Awaiting ($pending)', FarmerOrdersFilter.pending),
                  _chip('Confirmed ($confirmed)', FarmerOrdersFilter.confirmed),
                  _chip(
                    'Ready (${all.where((o) => o.status == OrderStatus.ready).length})',
                    FarmerOrdersFilter.ready,
                  ),
                  _chip(
                    'Completed (${all.where((o) => o.status == OrderStatus.completed).length})',
                    FarmerOrdersFilter.completed,
                  ),
                  _chip(
                    'Rejected (${all.where((o) => o.status == OrderStatus.rejected).length})',
                    FarmerOrdersFilter.rejected,
                  ),
                  _chip('All orders', FarmerOrdersFilter.all),
                ],
              ),
              const SizedBox(height: 20),
              if (orders.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 18,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.inbox_outlined, size: 44, color: muted),
                      const SizedBox(height: 16),
                      Text(
                        all.isEmpty
                            ? 'No orders for this farm yet'
                            : 'No orders in this category',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        all.isEmpty
                            ? 'Create a buyer order from an offer by ${farm.name}. It will appear here on this device.'
                            : 'Change the filter to see this farm’s other orders.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: muted, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      if (all.isNotEmpty)
                        OutlinedButton(
                          onPressed: () =>
                              setState(() => _filter = FarmerOrdersFilter.all),
                          child: const Text('Show all farm orders'),
                        ),
                    ],
                  ),
                )
              else
                for (final order in orders)
                  OrderListCard(
                    key: Key('farmer-order-${order.id}'),
                    order: order,
                    showBuyer: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => OrderDetailsScreen(
                          orderId: order.id,
                          farmId: farmId,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 10),
              Text(
                store.sessionOnly
                    ? 'Changes are kept for this session only.'
                    : 'Changes are saved on this device and appear in the buyer’s order history.',
                style: const TextStyle(fontSize: 12, color: muted, height: 1.5),
              ),
              if (store.loadFailed)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Previous history could not be loaded and has not been overwritten.',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, FarmerOrdersFilter filter) => ChoiceChip(
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
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label);
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        label,
        style: const TextStyle(color: Color(0xFFBED2C9), fontSize: 12),
      ),
    ],
  );
}
