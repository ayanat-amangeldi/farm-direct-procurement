import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Local vector artwork keeps the prototype independent of image services.
class ProduceArt extends StatelessWidget {
  const ProduceArt(this.productId, {super.key});
  final String productId;

  static Color background(String id) => switch (id) {
    'potatoes' => const Color(0xFFF0E9D8),
    'carrots' => const Color(0xFFF9E9D7),
    'tomatoes' => const Color(0xFFF6E3DE),
    'cucumbers' => const Color(0xFFE5EEDB),
    'apples' => const Color(0xFFEEECD5),
    _ => const Color(0xFFF2EBD7),
  };

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      painter: _ProducePainter(productId),
      size: Size.infinite,
    ),
  );
}

class _ProducePainter extends CustomPainter {
  const _ProducePainter(this.id);
  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = math.min(size.width / 200, size.height / 130);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 43), width: 132, height: 14),
      Paint()..color = const Color(0x18000000),
    );
    if (id == 'potatoes') {
      _potato(canvas, const Offset(-35, 4), -0.35, const Color(0xFFB78B53));
      _potato(canvas, const Offset(30, -14), 0.6, const Color(0xFFC69C63));
      _potato(canvas, const Offset(18, 23), -0.1, const Color(0xFFD5B079));
    } else if (id == 'carrots') {
      for (var i = 0; i < 3; i++) {
        canvas.save();
        canvas.translate((i - 1) * 36, i.isEven ? 0 : -8);
        canvas.rotate((i - 1) * 0.25);
        final body = Path()
          ..moveTo(-15, -23)
          ..quadraticBezierTo(-23, -35, 14, -27)
          ..quadraticBezierTo(22, -22, 2, 48)
          ..quadraticBezierTo(-2, 55, -15, -23);
        canvas.drawPath(
          body,
          Paint()
            ..color = i == 1
                ? const Color(0xFFE27C35)
                : const Color(0xFFF19446),
        );
        for (var j = 0; j < 3; j++) {
          canvas.drawLine(
            Offset(-2, -26),
            Offset((j - 1) * 12, -56),
            Paint()
              ..color = const Color(0xFF56814B)
              ..strokeWidth = 6
              ..strokeCap = StrokeCap.round,
          );
        }
        canvas.drawLine(
          const Offset(-9, -4),
          const Offset(2, -8),
          Paint()
            ..color = const Color(0xFFC7672B)
            ..strokeWidth = 2,
        );
        canvas.restore();
      }
    } else if (id == 'tomatoes' || id == 'apples') {
      for (var i = 0; i < 3; i++) {
        final center = Offset((i - 1) * 42, i == 1 ? -15 : 10);
        final color = id == 'tomatoes'
            ? (i == 1 ? const Color(0xFFD45A46) : const Color(0xFFE77558))
            : (i == 0 ? const Color(0xFF93A653) : const Color(0xFFB9704E));
        canvas.drawOval(
          Rect.fromCenter(center: center, width: 60, height: 57),
          Paint()..color = color,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: center + const Offset(-12, -9),
            width: 12,
            height: 18,
          ),
          Paint()..color = const Color(0x30FFFFFF),
        );
        final top = center + const Offset(0, -25);
        for (var j = 0; j < 5; j++) {
          final angle = j * math.pi * 2 / 5;
          canvas.drawLine(
            top,
            top + Offset(math.cos(angle) * 14, math.sin(angle) * 9),
            Paint()
              ..color = const Color(0xFF54713C)
              ..strokeWidth = 4
              ..strokeCap = StrokeCap.round,
          );
        }
      }
    } else if (id == 'cucumbers') {
      for (var i = 0; i < 3; i++) {
        canvas.save();
        canvas.translate((i - 1) * 32, i == 1 ? -4 : 4);
        canvas.rotate(0.5);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-15, -49, 30, 98),
            const Radius.circular(17),
          ),
          Paint()
            ..color = i == 1
                ? const Color(0xFF547643)
                : const Color(0xFF779350),
        );
        for (var j = 0; j < 6; j++) {
          canvas.drawCircle(
            Offset(j.isEven ? -6 : 5, -32 + j * 12),
            1.7,
            Paint()..color = const Color(0xFFB6C681),
          );
        }
        canvas.restore();
      }
    } else {
      for (var i = 0; i < 5; i++) {
        canvas.save();
        canvas.translate((i - 2) * 19, i.isEven ? 0 : 10);
        canvas.rotate((i - 2) * 0.18);
        canvas.drawLine(
          const Offset(0, -45),
          const Offset(0, 50),
          Paint()
            ..color = const Color(0xFF9C814C)
            ..strokeWidth = 2,
        );
        for (var j = 0; j < 5; j++) {
          for (final side in [-1.0, 1.0]) {
            canvas.save();
            canvas.translate(side * 5, -33 + j * 12);
            canvas.rotate(side * 0.6);
            canvas.drawOval(
              const Rect.fromLTWH(-4, -10, 8, 17),
              Paint()..color = const Color(0xFFD5B66A),
            );
            canvas.restore();
          }
        }
        canvas.restore();
      }
    }
    canvas.restore();
  }

  void _potato(Canvas canvas, Offset center, double angle, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-34, -24, 68, 48),
        const Radius.circular(25),
      ),
      Paint()..color = color,
    );
    canvas.drawOval(
      const Rect.fromLTWH(-23, -17, 36, 14),
      Paint()..color = const Color(0x22FFFFFF),
    );
    for (final point in [
      const Offset(-18, 4),
      const Offset(8, -9),
      const Offset(20, 7),
      const Offset(-4, 14),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: point, width: 4, height: 2.5),
        Paint()..color = const Color(0x5574532E),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ProducePainter oldDelegate) => oldDelegate.id != id;
}
