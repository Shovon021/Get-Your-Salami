import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Slightly longer for premium feel
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic),
    );

    _progressController.forward().then((_) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5E9), // Soft Mint
                  Color(0xFFC8E6C9), // Green Tint
                  Color(0xFFA5D6A7), // Fresh Green
                ],
              ),
            ),
          ),

          // 2. Animated Background Shapes (Orbs)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF43A047).withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF4CAF50).withValues(alpha: 0.2), blurRadius: 60, spreadRadius: 10),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2), duration: 4.seconds),
          ),
          Positioned(
            bottom: -50,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF66BB6A).withValues(alpha: 0.1),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: 30, duration: 5.seconds),
          ),

          // 3. Glass Card Content
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4), // Frosted glass
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(2), // Border gap
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2E7D32), width: 2),
                        ),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            // Fallback gradient if image fails
                            gradient: LinearGradient(
                              colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icon.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Text(
                                  "S", 
                                  style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        "SALAMI",
                        style: GoogleFonts.syne(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B5E20),
                          letterSpacing: 4,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5, end: 0),

                      const SizedBox(height: 8),

                      Text(
                        "Premium Experience",
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: const Color(0xFF388E3C),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 32),

                      // Progress Bar
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _progressAnimation.value,
                                  backgroundColor: const Color(0xFFE8F5E9),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${(_progressAnimation.value * 100).toInt()}%",
                                style: GoogleFonts.montserrat(fontSize: 10, color: const Color(0xFF1B5E20)),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1,1), curve: Curves.easeOutQuint),
          ),

          // 4. Developer Signature (Bottom)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "DEVELOPED BY",
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    letterSpacing: 3,
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Adnan Al Mim",
                  style: GoogleFonts.italianno(
                    fontSize: 24,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1.seconds),
          ),
        ],
      ),
    );
  }
}
