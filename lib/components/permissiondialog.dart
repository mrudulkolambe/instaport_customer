import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/constants/svgs.dart';
import 'package:permission_handler/permission_handler.dart';


class PermissionDialog extends StatefulWidget {
  const PermissionDialog({super.key});

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.string(successSVG),
            Text(
              'Locaiton Permission Required',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'For managing orders and to track orders we need to get the permission of your location',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () {
                  openAppSettings();
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: accentColor,
                ),
                child: Center(
                  child: Text(
                    "Home",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
