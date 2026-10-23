import 'package:flutter/material.dart';
import '../admin/moderation.dart';
import '../auth/account.dart';
import '../catalog/models.dart';
import '../orders/order.dart';
import '../orders/order_store.dart';
import 'account_bar.dart';
import 'order_widgets.dart';
import 'order_details_screen.dart';
import 'shared.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;
  bool _busy = false;
  String _query = '';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _change({
    required String id,
    required String name,
    required bool account,
    required bool restrict,
  }) async {
    final store = OrderScope.of(context);
    final action = account
        ? (restrict ? 'Block account' : 'Unblock account')
        : (restrict ? 'Hide offer' : 'Restore offer');
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ModerationDialog(
        action: action,
        name: name,
        explanation: account
            ? restrict
                  ? 'This user will not be able to sign in. A farmer’s offers will also leave the buyer catalog. Existing orders are preserved.'
                  : 'This user will be able to sign in again. Offers explicitly hidden by an administrator will stay hidden.'
            : restrict
            ? 'This farmer offer will leave the buyer catalog. Existing orders and their agreed prices are preserved.'
            : 'This offer can return to the buyer catalog if the farmer is active. Stock and minimum quantity still apply.',
      ),
    );
    if (reason == null || !mounted) return;
    setState(() => _busy = true);
    try {
      if (account) {
        await store.setAccountBlocked(id, blocked: restrict, reason: reason);
      } else {
        await store.setOfferHidden(id, hidden: restrict, reason: reason);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$action: saved.')));
      }
    } on OrderException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _matches(String text) =>
      text.toLowerCase().contains(_query.trim().toLowerCase());

  @override
  Widget build(BuildContext context) {
    final store = OrderScope.of(context);
    if (store.currentUser?.role != AccountRole.admin) {
      return const Scaffold(
        body: Center(child: Text('Administrator account required.')),
      );
    }
    final accounts = store.accounts
        .where((a) => _matches('${a.name} ${a.email} ${a.role.label}'))
        .toList();
    final offers = store.offers
        .where(
          (o) => _matches(
            '${store.product(o.productId)?.name} ${o.farmName} ${o.location}',
          ),
        )
        .toList();
    final orders = store.orders
        .where(
          (o) => _matches(
            '${o.id} ${o.productName} ${o.farmName} ${o.contactName}',
          ),
        )
        .toList();
    final history = store.moderationHistory
        .where(
          (r) => _matches('${r.reason} ${r.targetId} ${_subject(store, r)}'),
        )
        .toList();
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
                'Manage account access and offer visibility on this device. Products are moderated per farmer offer. Existing orders keep their agreed terms.',
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
                runSpacing: 8,
                children: [
                  for (final (index, label) in [
                    'Accounts',
                    'Offers',
                    'Orders',
                    'History',
                  ].indexed)
                    ChoiceChip(
                      key: Key('admin-${label.toLowerCase()}'),
                      label: Text(label),
                      selected: _tab == index,
                      onSelected: (_) {
                        if (_tab == index) return;
                        setState(() {
                          _tab = index;
                          _query = '';
                          _search.clear();
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                key: ValueKey('admin-search-$_tab'),
                controller: _search,
                decoration: const InputDecoration(
                  labelText: 'Search this section',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 16),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(),
                ),
              if (_tab == 0 && accounts.isEmpty ||
                  _tab == 1 && offers.isEmpty ||
                  _tab == 2 && orders.isEmpty ||
                  _tab == 3 && history.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _query.isNotEmpty
                        ? 'No matches. Try another search.'
                        : _tab == 2
                        ? 'No orders yet.'
                        : _tab == 3
                        ? 'No moderation actions yet.'
                        : 'No items yet.',
                  ),
                ),
              if (_tab == 0)
                for (final account in accounts) _accountCard(store, account),
              if (_tab == 1)
                for (final offer in offers) _offerCard(store, offer),
              if (_tab == 2)
                for (final order in orders)
                  OrderListCard(
                    order: order,
                    showBuyer: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => OrderDetailsScreen(orderId: order.id),
                      ),
                    ),
                  ),
              if (_tab == 3)
                for (final record in history)
                  _panel(
                    key: ValueKey(record),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _subject(store, record),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          record.target == ModerationTarget.account
                              ? record.restricted
                                    ? 'Account blocked'
                                    : 'Account unblocked'
                              : record.restricted
                              ? 'Offer hidden'
                              : 'Offer restored',
                          style: const TextStyle(
                            color: forest,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(record.reason),
                        const SizedBox(height: 8),
                        Text(
                          '${orderDate(record.at)} · ${record.adminId}',
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 16),
              Text(
                store.sessionOnly
                    ? 'Local demo · changes are kept for this session only.'
                    : 'Local demo · changes are saved on this device only.',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
              if (store.loadFailed)
                const Text(
                  'Previous saved data could not be loaded and has not been overwritten.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel({Key? key, required Widget child}) => Container(
    key: key,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: lineColor),
    ),
    child: child,
  );

  Widget _accountCard(OrderStore store, DemoAccount account) {
    final blocked = store.isAccountBlocked(account.id);
    final protected = account.role == AccountRole.admin;
    final record = store.accountRestriction(account.id);
    return _panel(
      key: Key('admin-account-${account.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            account.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            '${account.role.label} · ${account.email}',
            style: const TextStyle(color: muted, height: 1.5),
          ),
          const SizedBox(height: 10),
          _status(
            protected
                ? 'Protected administrator'
                : blocked
                ? 'Blocked'
                : 'Active',
            restricted: blocked,
          ),
          if (record != null) ...[
            const SizedBox(height: 10),
            Text(
              'Last review: ${record.reason}',
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
            Text(
              orderDate(record.at),
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ],
          if (!protected) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: Key('moderate-account-${account.id}'),
              onPressed: _busy
                  ? null
                  : () => _change(
                      id: account.id,
                      name: account.name,
                      account: true,
                      restrict: !blocked,
                    ),
              icon: Icon(blocked ? Icons.lock_open : Icons.block, size: 18),
              label: Text(blocked ? 'Unblock account' : 'Block account'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _offerCard(OrderStore store, FarmerOffer offer) {
    final hidden = store.isOfferHidden(offer.id);
    final farmBlocked = store.isFarmBlocked(offer.farmId);
    final record = store.offerRestriction(offer.id);
    final name =
        '${store.product(offer.productId)?.name ?? 'Product'} · ${offer.farmName}';
    return _panel(
      key: Key('admin-offer-${offer.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(
            '${money(offer.pricePerKg)} / kg · ${store.availableKg(offer)} kg available\n${offer.location}',
            style: const TextStyle(color: muted, height: 1.5),
          ),
          const SizedBox(height: 10),
          _status(
            hidden
                ? 'Hidden by administrator'
                : farmBlocked
                ? 'Unavailable · farmer blocked'
                : 'Visible in catalog',
            restricted: hidden || farmBlocked,
          ),
          if (record != null) ...[
            const SizedBox(height: 10),
            Text(
              'Last review: ${record.reason}',
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
            Text(
              orderDate(record.at),
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ],
          if (farmBlocked)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'This farmer must be unblocked before any of their offers can return to the catalog.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.5),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: Key('moderate-offer-${offer.id}'),
            onPressed: _busy
                ? null
                : () => _change(
                    id: offer.id,
                    name: name,
                    account: false,
                    restrict: !hidden,
                  ),
            icon: Icon(
              hidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
            ),
            label: Text(hidden ? 'Restore offer' : 'Hide offer'),
          ),
        ],
      ),
    );
  }

  Widget _status(String label, {required bool restricted}) => Text(
    label,
    style: TextStyle(
      color: restricted ? const Color(0xFFAA3030) : forest,
      fontWeight: FontWeight.w600,
      height: 1.5,
    ),
  );

  String _subject(OrderStore store, ModerationRecord record) {
    if (record.target == ModerationTarget.account) {
      return store.accounts
              .where((a) => a.id == record.targetId)
              .firstOrNull
              ?.name ??
          record.targetId;
    }
    final offer = store.offer(record.targetId);
    return offer == null
        ? record.targetId
        : '${store.product(offer.productId)?.name ?? 'Product'} · ${offer.farmName}';
  }
}

class _ModerationDialog extends StatefulWidget {
  const _ModerationDialog({
    required this.action,
    required this.name,
    required this.explanation,
  });
  final String action, name, explanation;
  @override
  State<_ModerationDialog> createState() => _ModerationDialogState();
}

class _ModerationDialogState extends State<_ModerationDialog> {
  final _reason = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('${widget.action}?'),
    content: SingleChildScrollView(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(widget.explanation),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('moderation-reason'),
              controller: _reason,
              minLines: 2,
              maxLines: 4,
              maxLength: 300,
              validator: moderationReasonError,
              decoration: const InputDecoration(
                labelText: 'Reason for this decision',
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('confirm-moderation'),
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.of(context).pop(_reason.text.trim());
          }
        },
        child: Text(widget.action),
      ),
    ],
  );
}
