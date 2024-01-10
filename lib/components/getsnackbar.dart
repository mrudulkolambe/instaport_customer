import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instaport_customer/constants/colors.dart';

class GetSnackbar {
  static void info(String msg) {
    Get.snackbar(
      "Info",
      msg,
      animationDuration: const Duration(milliseconds: 300),
      dismissDirection: DismissDirection.up,
      backgroundColor: accentColor.withOpacity(0.7),
    );
  }
}
