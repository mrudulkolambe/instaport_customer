import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/constants/svgs.dart';
import 'package:instaport_customer/screens/home.dart';

class OrderSuccessDialog extends StatefulWidget {
  const OrderSuccessDialog({super.key});

  @override
  State<OrderSuccessDialog> createState() => _OrderSuccessDialogState();
}

class _OrderSuccessDialogState extends State<OrderSuccessDialog> {
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
              'Order Successful',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Your package will be picked up by the courier, please wait for some time',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () {
                Get.back();
                Get.to(() => const Home());
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
