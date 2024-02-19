import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/constants/colors.dart';

class ConfirmController extends GetxController {
  double getAbsoluteDifference(double a, double b) {
    return (a - b);
  }

  Future<bool> showConfirmDialog(
      double oldAmount, double newAmount, String payment_method) async {
    double diff = getAbsoluteDifference(oldAmount, newAmount);
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
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Amount: Rs.$newAmount"),
          if (payment_method != "cod")
            Text(
              diff == 0
                  ? 'Are you sure you want to update the order?'
                  : diff < 0
                      ? "Rs.${diff.abs().toPrecision(2)} will be added to your next order"
                      : "Rs.${diff.abs().toPrecision(2)} will be saved for your next wallet",
            ),
          if (payment_method == "cod")
            Text(
                "Rs.${diff.abs().toPrecision(2)} has been added to your amount"),
        ],
      ),
      textConfirm: 'Yes',
      titleStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
      ),
      middleTextStyle: GoogleFonts.poppins(),
      textCancel: 'No',
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
