import 'package:flutter/material.dart';
import '../catalog/models.dart';
import '../orders/order_store.dart';
import 'account_bar.dart';
import 'order_widgets.dart';
import 'order_details_screen.dart';
import 'shared.dart';

/// Read-only oversight for the local prototype, not a moderation backend.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final store = OrderScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Administrator')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              const AccountBar(),
              const SizedBox(height: 20),
              const Text(
                'Marketplace overview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Review accounts, published offers and procurement activity on this device. This prototype provides read-only oversight; account blocking, listing moderation and real transactions are not connected.',
                style: TextStyle(color: muted, height: 1.5),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final entry in [
                    (store.accounts.length, 'Accounts'),
                    (store.offers.length, 'Offers'),
                    (store.orders.length, 'Orders'),
                  ])
                    Container(
                      width: 138,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: ink,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.$1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            entry.$2,
                            style: const TextStyle(color: Color(0xFFBED2C9)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 8,
                children: [
                  for (final (index, label) in [
                    'Accounts',
                    'Offers',
                    'Orders',
                  ].indexed)
                    ChoiceChip(
                      key: Key('admin-${label.toLowerCase()}'),
                      label: Text(label),
                      selected: _tab == index,
                      onSelected: (_) => setState(() => _tab = index),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_tab == 0)
                for (final account in store.accounts)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(account.name),
                      subtitle: Text('${account.role.label}\n${account.email}'),
                      isThreeLine: true,
                    ),
                  ),
              if (_tab == 1)
                for (final offer in store.offers)
                  Card(
                    child: ListTile(
                      title: Text(
                        '${store.product(offer.productId)?.name ?? 'Product'} · ${offer.farmName}',
                      ),
                      subtitle: Text(
                        '${money(offer.pricePerKg)} / kg · ${store.availableKg(offer)} kg available\n${offer.location}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
              if (_tab == 2 && store.orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No orders yet.'),
                ),
              if (_tab == 2)
                for (final order in store.orders)
                  OrderListCard(
                    order: order,
                    showBuyer: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => OrderDetailsScreen(orderId: order.id),
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
