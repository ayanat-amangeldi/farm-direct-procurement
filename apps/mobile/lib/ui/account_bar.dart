import 'package:flutter/material.dart';
import '../orders/order_store.dart';
import 'shared.dart';

class AccountBar extends StatelessWidget {
  const AccountBar({super.key});
  @override
  Widget build(BuildContext context) {
    final store = OrderScope.of(context);
    final account = store.currentUser;
    if (account == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 19,
            backgroundColor: Color(0xFFE4EDE6),
            child: Icon(Icons.person_outline, color: forest, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${account.role.label} · local demo',
                  style: const TextStyle(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('sign-out'),
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout, size: 21),
            onPressed: () {
              try {
                store.signOut();
              } on OrderException catch (error) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error.message)));
              }
            },
          ),
        ],
      ),
    );
  }
}
