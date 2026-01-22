import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/splash_screen.dart';

void main() {
  runApp(const GetYourSalamiApp());
}

class GetYourSalamiApp extends StatelessWidget {
  const GetYourSalamiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salami',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE8F5E9), // Light Mint
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: const Color(0xFF1B5E20),
          displayColor: const Color(0xFF1B5E20),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2E7D32), // Green
          secondary: Color(0xFFFFB300), // Amber Gold
          surface: Color(0xFFFFFFFF),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
