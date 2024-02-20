import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/constants/colors.dart';

class RemoveConfirm extends GetxController {
  Future<bool> showRemoveConfirmDialog() async {
    return await Get.defaultDialog(
      barrierDismissible: false,
      onWillPop: () async {
        return false;
      },
      cancel: GestureDetector(
        onTap: () => Get.back(result: false),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 2,
                color: accentColor,
              ),
              borderRadius: BorderRadius.circular(8)),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 10,
            ),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ),
      ),
      confirm: GestureDetector(
        onTap: () => Get.back(result: true),
        child: Container(
          decoration: BoxDecoration(
              color: accentColor,
              border: Border.all(
                width: 2,
                color: accentColor,
              ),
              borderRadius: BorderRadius.circular(8)),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 10,
            ),
            child: Text(
              "Confirm",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ),
      ),
      contentPadding: const EdgeInsets.all(15),
      title: 'Confirm',
      content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Are you sure you want to remove the drop point?"),
      ]),
      titleStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
      ),
      middleTextStyle: GoogleFonts.poppins(),
      confirmTextColor: Colors.white,
      buttonColor: accentColor,
      cancelTextColor: Colors.black,
      onConfirm: () {
        Get.back(result: true);
      },
      onCancel: () {
        Get.back(result: false);
      },
    );
  }
}
