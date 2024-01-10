import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/screens/new_order.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: const CustomBottomNavigationBar(),
        body: SafeArea(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/home.png",
                  width: 230,
                  height: 230,
                ),
                Text(
                  "Send a Package",
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    "Pickup and delivery of documents, gifts, flowers, food, and more.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () => Get.to(() => const Neworder()),
                  child: Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * 0.65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: accentColor,
                    ),
                    child: Center(
                      child: Text(
                        "Create an Order",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ],
            ),
          ],
        )),
      ),
    );
  }
}
