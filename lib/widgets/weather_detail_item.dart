import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const WeatherDetailItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lato(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
