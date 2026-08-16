import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';

class GlitterBackground extends StatelessWidget {
  const GlitterBackground({
    required this.darkMode,
    required this.child,
    super.key,
  });

  final bool darkMode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = darkMode
        ? const [Color(0xFF000000), Color(0xFF050403), Color(0xFF0B0802)]
        : const [Color(0xFFFFFFFF), Color(0xFFFFFDF7), Color(0xFFFFF5D7)];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: CustomPaint(
        painter: _GlitterPainter(darkMode: darkMode),
        child: child,
      ),
    );
  }
}

class _GlitterPainter extends CustomPainter {
  const _GlitterPainter({required this.darkMode});

  final bool darkMode;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(8246);
    final glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    final dot = Paint();

    for (var i = 0; i < 68; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final lowerBoost = .35 + (y / size.height) * .65;
      final radius = 1.2 + random.nextDouble() * (i % 8 == 0 ? 8 : 3.5);
      final color = i.isEven ? AppColors.gold : AppColors.lightGold;
      glow.color = color.withValues(
        alpha: (darkMode ? .13 : .18) * lowerBoost,
      );
      dot.color = (darkMode ? Colors.white : AppColors.gold).withValues(
        alpha: (darkMode ? .30 : .24) * lowerBoost,
      );
      canvas.drawCircle(Offset(x, y), radius * 2.2, glow);
      canvas.drawCircle(Offset(x, y), radius, dot);
      if (i % 11 == 0) {
        final sparkle = Paint()
          ..color = AppColors.lightGold.withValues(
            alpha: darkMode ? .48 : .42,
          )
          ..strokeWidth = 1.1;
        final length = radius * 3.2;
        canvas.drawLine(Offset(x - length, y), Offset(x + length, y), sparkle);
        canvas.drawLine(Offset(x, y - length), Offset(x, y + length), sparkle);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GlitterPainter oldDelegate) =>
      darkMode != oldDelegate.darkMode;
}
