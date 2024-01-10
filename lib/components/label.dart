import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Label extends StatelessWidget {
  const Label({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        )
      ],
    );
  }
}
