import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';
import 'package:instaport_customer/screens/profile.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title:  CustomAppBar(
          title: "About",
          back: () => Get.to(() => const Profile()),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "About Instaport",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Instaport provides value to the customers, and ready to provide best service with same day delivery. it is the leading platform, for B2B and B2C and easy to access and can work as per costumer convenience.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                "We have just begun our is to provide world's best delivery service from end-to-end logistics platform and company motto is to provide the premium service to the customer.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                "Instaport do have quality rated and well profiled delivery executives with good relation and will work as a helping hand for the customers.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
