import 'package:flutter/material.dart';

const forest = Color(0xFF17634A);
const ink = Color(0xFF192D28);
const muted = Color(0xFF697671);
const canvasColor = Color(0xFFF6F7F8);
const lineColor = Color(0xFFE3E8E5);

class DemoLabel extends StatelessWidget {
  const DemoLabel({super.key});
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.info_outline, size: 14, color: muted),
      SizedBox(width: 5),
      Flexible(
        child: Text(
          'Demo data · sample prices',
          style: TextStyle(color: muted, fontSize: 12),
        ),
      ),
    ],
  );
}

class Fact extends StatelessWidget {
  const Fact(this.icon, this.label, {super.key});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: muted),
      const SizedBox(width: 6),
      Flexible(
        child: Text(label, style: const TextStyle(color: muted, fontSize: 13)),
      ),
    ],
  );
}

class EmptyResults extends StatelessWidget {
  const EmptyResults({
    required this.title,
    required this.message,
    required this.onReset,
    super.key,
  });
  final String title;
  final String message;
  final VoidCallback onReset;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
    child: Column(
      children: [
        const Icon(Icons.search_off_rounded, size: 44, color: muted),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onReset, child: const Text('Reset filters')),
      ],
    ),
  );
}
