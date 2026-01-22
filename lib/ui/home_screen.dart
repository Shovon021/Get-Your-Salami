import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../logic/audio_manager.dart';
import '../../logic/theme_manager.dart';
import 'widgets/developer_signature.dart';
import 'widgets/luxury_wheel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    AudioManager().init();
    ThemeManager().init();
    ThemeManager().addListener(_onThemeChange);
  }

  void _onThemeChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _confettiController.dispose();
    ThemeManager().removeListener(_onThemeChange);
    super.dispose();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7), // Milky glass
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
              child: DefaultTabController(
                length: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("SETTINGS", style: GoogleFonts.syne(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black54),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    
                    // Tab Bar
                    TabBar(
                      indicatorColor: ThemeManager().colors.accent,
                      labelColor: ThemeManager().colors.accent,
                      unselectedLabelColor: Colors.black45,
                      labelStyle: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
                      tabs: const [
                        Tab(icon: Icon(Icons.music_note), text: "AUDIO"),
                        Tab(icon: Icon(Icons.palette), text: "THEME"),
                        Tab(icon: Icon(Icons.person), text: "ABOUT"),
                      ],
                    ),
                    
                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        children: [
                          // AUDIO TAB
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildSettingsTile(
                                  icon: Icons.music_note,
                                  title: "Background Music",
                                  subtitle: "Ambient loop",
                                  value: AudioManager().isMusicOn,
                                  onChanged: (val) {
                                    setDialogState(() {});
                                    AudioManager().toggleMusic(val);
                                  },
                                ),
                                const Gap(12),
                                _buildSettingsTile(
                                  icon: Icons.volume_up,
                                  title: "Sound Effects",
                                  subtitle: "Tick, spin, win sounds",
                                  value: AudioManager().isSfxOn,
                                  onChanged: (val) {
                                    setDialogState(() {});
                                    AudioManager().toggleSfx(val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          // THEME TAB
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("SELECT THEME", style: GoogleFonts.montserrat(color: Colors.black54, fontSize: 11, letterSpacing: 2)),
                                const Gap(16),
                                Expanded(
                                  child: GridView.count(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    children: AppTheme.values.map((theme) {
                                      final colors = ThemeManager.themes[theme]!;
                                      final isSelected = ThemeManager().currentTheme == theme;
                                      return GestureDetector(
                                        onTap: () {
                                          ThemeManager().setTheme(theme);
                                          setDialogState(() {});
                                          setState(() {});
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [colors.gradientStart, colors.gradientMiddle, colors.gradientEnd],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSelected ? colors.gold : Colors.black12,
                                              width: isSelected ? 3 : 1,
                                            ),
                                            boxShadow: isSelected ? [
                                              BoxShadow(color: colors.accent.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2),
                                            ] : null,
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              if (isSelected) Icon(Icons.check_circle, color: colors.gold, size: 24),
                                              const Gap(4),
                                              Text(
                                                colors.name.split(' ').first,
                                                style: GoogleFonts.montserrat(color: Colors.black87, fontSize: 9, fontWeight: FontWeight.w600),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // ABOUT TAB
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Developer Avatar
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [ThemeManager().colors.accent, ThemeManager().colors.gold],
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: ThemeManager().colors.accent.withValues(alpha: 0.4), blurRadius: 15),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text("AM", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const Gap(16),
                                Text("Adnan Al Mim", style: GoogleFonts.syne(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                                const Gap(4),
                                Text("Mobile App Developer", style: GoogleFonts.montserrat(color: ThemeManager().colors.accent, fontSize: 12, letterSpacing: 1)),
                                const Gap(16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildAboutRow(Icons.code, "Flutter & Dart Expert"),
                                      const Divider(color: Colors.black12, height: 16),
                                      _buildAboutRow(Icons.palette, "UI/UX Designer"),
                                      const Divider(color: Colors.black12, height: 16),
                                      _buildAboutRow(Icons.rocket_launch, "Passionate Builder"),
                                    ],
                                  ),
                                ),
                                const Gap(16),
                                Text("Get Your Salami v1.0.0", style: GoogleFonts.montserrat(color: Colors.black38, fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
        }
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThemeManager().colors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ThemeManager().colors.accent, size: 20),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.montserrat(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.montserrat(color: Colors.black54, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: ThemeManager().colors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: ThemeManager().colors.gold, size: 18),
        const Gap(12),
        Text(text, style: GoogleFonts.montserrat(color: Colors.black87, fontSize: 12)),
      ],
    );
  }


  Future<void> _handleSpinEnd(int amount) async {
    // 1. Play Win Sound
    AudioManager().playWin();
    
    // 2. Play Confetti
    if (amount > 0) {
      _confettiController.play();
      _showWinDialog(amount);
    }
  }

  void _showWinDialog(int amount) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2E4A).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF00CC).withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CONGRATULATIONS!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2.0,
                ),
              ),
              const Gap(16),
              Text(
                "YOU WON",
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const Gap(8),
              Text(
                "$amount TAKA",
                style: GoogleFonts.syne(
                  color: const Color(0xFFFFD700),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const Gap(24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF00CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("CLAIM REWARD"),
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient (Dynamic Theme)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeManager().colors.gradientStart,
                  ThemeManager().colors.gradientMiddle,
                  ThemeManager().colors.gradientEnd,
                ],
              ),
            ),
          ),



          // 2. Mesh Gradient Overlay (Simulated via blurred circles)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6A0572).withValues(alpha: 0.4),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2), duration: 4.seconds),
          ),
          
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00C9A7).withValues(alpha: 0.2),
              ),
            ),
          ),

          // 3. Glass Overlay
          Container(
            color: Colors.black.withValues(alpha: 0.2), // Slight tint
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        children: [
                          Text(
                            "GET YOUR SALAMI",
                            style: GoogleFonts.syne(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(color: const Color(0xFFFF00CC).withValues(alpha: 0.8), blurRadius: 15),
                              ],
                            ),
                          ),
                          const Gap(8),
                          Text(
                            "Spin to Win Big!",
                            style: GoogleFonts.montserrat(
                              color: Colors.white70,
                              fontSize: 14,
                              letterSpacing: 4.0,
                            ),
                          ),
                        ],
                      ).animate().slideY(begin: -1, duration: 800.ms, curve: Curves.easeOutQuart),
                    ),

                    // The Wheel
                    LuxuryWheel(onSpinEnd: _handleSpinEnd)
                        .animate()
                        .fadeIn(duration: 1.seconds)
                        .scale(curve: Curves.easeOutBack),

                    // Footer / Signature
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: const DeveloperSignature()
                          .animate(delay: 500.ms)
                          .fadeIn()
                          .slideY(begin: 1, curve: Curves.easeOutQuart),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 4. Settings Button (Fixed Position - Highest Z-Index)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: _showSettingsDialog,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.settings, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Confetti Overlay (Top Center)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFFFFD700),
                Color(0xFFFF00CC),
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

