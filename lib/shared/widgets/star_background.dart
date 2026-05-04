import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StarBackground extends StatefulWidget {
  final Widget child;

  const StarBackground({super.key, required this.child});

  @override
  State<StarBackground> createState() => _StarBackgroundState();
}

class _StarBackgroundState extends State<StarBackground> with TickerProviderStateMixin {
  late final List<_Star> _stars;
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _stars = List.generate(50, (_) => _Star(rng));
    _controllers = _stars.map((s) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 2000 + rng.nextInt(2000)),
      )..repeat(reverse: true);
      return ctrl;
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _StarPainter(_stars, _controllers),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double delay;

  _Star(Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        delay = rng.nextDouble();
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final List<AnimationController> controllers;

  _StarPainter(this.stars, this.controllers) : super(repaint: controllers.first);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.foreground;
    for (int i = 0; i < stars.length; i++) {
      final opacity = 0.1 + controllers[i].value * 0.4;
      paint.color = AppColors.foreground.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(stars[i].x * size.width, stars[i].y * size.height),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
