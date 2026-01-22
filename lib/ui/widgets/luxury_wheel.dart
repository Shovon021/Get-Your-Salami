import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../logic/audio_manager.dart';
import '../../logic/theme_manager.dart';

class LuxuryWheel extends StatefulWidget {
  final Future<void> Function(int amount) onSpinEnd;

  const LuxuryWheel({super.key, required this.onSpinEnd});

  @override
  State<LuxuryWheel> createState() => _LuxuryWheelState();
}

class _LuxuryWheelState extends State<LuxuryWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentRotation = 0.0;
  
  // Segments and Probabilities
  final List<WheelSegment> _segments = [
    WheelSegment(10, const Color(0xFF6A0572), 0.35),
    WheelSegment(20, const Color(0xFFAB83A1), 0.25),
    WheelSegment(50, const Color(0xFFE55C9C), 0.20),
    WheelSegment(100, const Color(0xFFFF8D29), 0.10),
    WheelSegment(200, const Color(0xFFF9F871), 0.10),
    WheelSegment(500, const Color(0xFF00C9A7), 0.00), // 0% Chance
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // Maximum Thrill (12s)
    );
    _controller.addListener(() {
      setState(() {
        final double prevRotation = _currentRotation;
        _currentRotation = _animation.value;
        
        // Calculate Tick
        // We know segmentAngle is 60 deg (pi/3).
        // Check if we crossed a threshold?
        // Simpler: Just track accumulated delta.
        // Actually, since it's monotonic (always increasing/decreasing), delta is simple.
        
        final double delta = (_currentRotation - prevRotation).abs();
        _rotationAccumulator += delta;
        
        const double segmentAngle = pi / 3;
        if (_rotationAccumulator >= segmentAngle) {
          AudioManager().playTick();
          _rotationAccumulator -= segmentAngle;
        }
      });
    });
  }

  double _rotationAccumulator = 0.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spin() {
    if (_controller.isAnimating) return;

    // 1. Determine Winner based on Probability
    final double rand = Random().nextDouble();
    double accum = 0.0;
    WheelSegment? winner;
    
    // Shuffle logic slightly for randomness? No, accumulative is fine.
    // We iterate to find where rand falls.
    for (var seg in _segments) {
      accum += seg.probability;
      if (rand <= accum) {
        winner = seg;
        break;
      }
    }
    // Fallback if float math is slightly off (should contain 1.0 total)
    winner ??= _segments.first; 

    // 2. Calculate Angle to land on Winner
    // Each segment is 60 degrees (360 / 6)
    const double segmentAngle = 2 * pi / 6;
    final int winnerIndex = _segments.indexOf(winner);
    
    // We want the pointer (at TOP, -pi/2) to point to the winner.
    // If the wheel rotates clockwise, the segment at index `i` moves AWAY.
    // Target rotation = (Full Spins) + (Offset to align segment with top).
    
    // Let's assume segment 0 starts at top.
    // To land segment `i` at top, we need to rotate `-(i * segmentAngle)`.
    // Adding noise so it doesn't land in the exact center of the segment every time.
    final double noise = (Random().nextDouble() - 0.5) * (segmentAngle * 0.8);
    
    // Full spins (5 to 10 rounds)
    final double fullSpins = 2 * pi * (5 + Random().nextInt(5));
    
    // The target is where we want to END up relative to 0.
    // 0 rotation = Segment 0 is at Top? 
    // Wait, standard unit circle: 0 is Right. 
    // In Canvas, we'll draw Segment 0 from -pi/2? No, let's just rotate the Canvas.
    // Let's settle: Segment 0 starts at -90deg (Top).
    // To get Segment 1 (at -30deg) to Top (-90deg), we rotate -60deg (-pi/3).
    // So targetRotation = - (index * segmentAngle) + noise + fullSpins.
    
    final double targetAngle = -(winnerIndex * segmentAngle) + noise + fullSpins;

    // 3. Animate
    _animation = Tween<double>(
      begin: _currentRotation % (2 * pi), // Reset to normalized start
      end: targetAngle,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));

    // Play spin whoosh at start
    AudioManager().playSpinWhoosh();

    _controller.forward(from: 0.0).then((_) {
      // Stop spin whoosh
      AudioManager().stopSpinWhoosh();
      HapticFeedback.heavyImpact(); // Final Thud
      widget.onSpinEnd(winner!.amount);
    });
    
    // Tick effect? Needs more complex listener, sticking to end haptic for now
    // Actually, light impact on start
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final wheelSize = size * 0.9; // 90% of available space
        
        return GestureDetector(
          onTap: spin,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow (Subtle Pulse)
              Container(
                width: wheelSize + 20,
                height: wheelSize + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ThemeManager().colors.accent.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .fade(begin: 0.6, end: 1.0, duration: 3.seconds),
              
              // The Wheel
              Transform.rotate(
                angle: _currentRotation,
                child: CustomPaint(
                  size: Size(wheelSize, wheelSize),
                  painter: _WheelPainter(_segments),
                ),
              ),
              
              // Center Cap
              Container(
                width: wheelSize * 0.18,
                height: wheelSize * 0.18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFFFFF8E5), Color(0xFFC6A355)],
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(
                    "SPIN",
                    style: TextStyle(
                      color: const Color(0xFF4A3B10),
                      fontWeight: FontWeight.bold,
                      fontSize: wheelSize * 0.04,
                    ),
                  ),
                ),
              ),
              
              // Pointer
              Positioned(
                top: 0,
                child: _Pointer(),
              ),
            ],
          ),
        );
      }
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<WheelSegment> segments;

  _WheelPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final double segmentAngle = 2 * pi / segments.length;

    // Start from -90 degrees (Top)
    double startAngle = -pi / 2 - (segmentAngle / 2); 
    // Wait, if I want index 0 to be centered at Top, 
    // it should span from -pi/2 - half_angle to -pi/2 + half_angle.
    
    for (var segment in segments) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = segment.color
        ..shader = RadialGradient(
          colors: [segment.color, segment.color.withValues(alpha: 0.8)],
        ).createShader(rect);

      // Draw Slice
      canvas.drawArc(rect, startAngle, segmentAngle, true, paint);

      // Draw Text
      _drawText(canvas, center, radius, startAngle, segmentAngle, "${segment.amount}");

      startAngle += segmentAngle;
    }
  }

  void _drawText(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final double midAngle = startAngle + sweepAngle / 2;
    // Position text at 70% of radius
    final double textRadius = radius * 0.7;
    final double x = center.dx + textRadius * cos(midAngle);
    final double y = center.dy + textRadius * sin(midAngle);

    canvas.save();
    canvas.translate(x, y);
    // Rotate text to match segment
    canvas.rotate(midAngle + pi / 2); 
    
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Pointer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10), // Adjust overlapping
      child: CustomPaint(
        size: const Size(30, 40),
        painter: _PointerPainter(),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    // Inverted Triangle
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    // Draw Shadow
    canvas.drawShadow(path, Colors.black54, 5.0, true);

    // Draw Shape
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WheelSegment {
  final int amount;
  final Color color;
  final double probability;

  WheelSegment(this.amount, this.color, this.probability);
}
