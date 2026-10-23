import 'package:flutter/material.dart';

/// Illustrative generated photography; not photos of real listed inventory.
class ProductPhoto extends StatelessWidget {
  const ProductPhoto(this.productId, {super.key});
  final String productId;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/products/$productId.png',
    fit: BoxFit.cover,
    excludeFromSemantics: true,
    errorBuilder: (context, error, stackTrace) => const ColoredBox(
      color: Color(0xFFE9ECE8),
      child: Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF8C9691), size: 28),
      ),
    ),
  );
}
