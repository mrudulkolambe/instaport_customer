import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/user.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/screens/about.dart';
import 'package:instaport_customer/screens/edit_profile.dart';
import 'package:instaport_customer/screens/login.dart';
import 'package:instaport_customer/screens/wallet.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _storage = GetStorage();
  final UserController userController = Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: CustomAppBar(
          title: "Profile",
          back: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: GetBuilder<UserController>(
              init: UserController(),
              builder: (controller) {
                return Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          onBackgroundImageError: (exception, stackTrace) {},
                          backgroundImage: NetworkImage(controller.user.image),
                          backgroundColor: accentColor,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.user.fullname,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              controller.user.mobileno,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.black38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const EditProfile()),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: accentColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 25,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Edit Profile",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 15,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // TODO: Change City
                    // Container(
                    //   width: MediaQuery.of(context).size.width - 50,
                    //   decoration: BoxDecoration(
                    //     border: Border.all(
                    //       width: 2,
                    //       color: accentColor,
                    //     ),
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //       vertical: 15.0,
                    //       horizontal: 25,
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Text(
                    //           "Change city",
                    //           style: GoogleFonts.poppins(
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ),
                    //         const Icon(
                    //           Icons.arrow_forward_ios_rounded,
                    //           size: 15,
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 15,
                    // ),
                    GestureDetector(
                      onTap: () => Get.to(() => const AboutUs()),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: accentColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 25,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "About us",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 15,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const Wallet()),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: accentColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 25,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Wallet",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 15,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () async {
                        _storage.remove("token");
                        Get.to(
                          () => const SplashScreen(),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: accentColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 25,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Logout",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 15,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
