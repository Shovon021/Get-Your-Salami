import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class DeveloperSignature extends StatelessWidget {
  const DeveloperSignature({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "DEVELOPED BY",
          style: GoogleFonts.montserrat(
            fontSize: 10,
            letterSpacing: 3.0,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Shimmer.fromColors(
          baseColor: const Color(0xFFC6A355), // Matte Gold
          highlightColor: const Color(0xFFFFF8E5), // Bright Gold
          period: const Duration(seconds: 3),
          child: Text(
            "Adnan Al Mim",
            style: GoogleFonts.italianno( // Classy script font
              fontSize: 36,
              color: const Color(0xFFC6A355),
              height: 1.0,
            ),
          ),
        ),
        Container(
          width: 40,
          height: 1,
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color(0xFFC6A355),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
