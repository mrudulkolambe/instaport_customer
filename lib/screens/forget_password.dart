import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/label.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/main.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/screens/login.dart';
import 'package:instaport_customer/utils/mask_fomatter.dart';
import 'package:instaport_customer/utils/toast_manager.dart';
import 'package:instaport_customer/utils/validator.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  var presscount = 0;
  final _storage = GetStorage();
  bool loading = false;

  InAppWebViewController? webView;
  String apptoken = "";

  void _setupJavaScriptHandler() {
    if (webView != null) {
      webView!.addJavaScriptHandler(
        handlerName: 'successForgetPassword',
        callback: (args) {
          _successForgetPassword();
        },
      );
      webView!.addJavaScriptHandler(
        handlerName: 'leaveForgetPassword',
        callback: (args) {
          _leaveVerifcation();
        },
      );
      webView!.addJavaScriptHandler(
        handlerName: 'successfunction',
        callback: (args) {
          _successForgetPassword();
        },
      );
      webView!.addJavaScriptHandler(
        handlerName: 'errorFunction',
        callback: (args) {
          _leaveVerifcation();
        },
      );
    }
  }

  void _successForgetPassword() {
    ToastManager.showToast("Password updated successfully!");
    Get.back();
    Get.to(() => const SplashScreen());
  }

  void _leaveVerifcation() {
    Get.back();
  }

  final TextEditingController phoneNumberController = TextEditingController();
  void handleVerify() async {
    setState(() {
      loading = true;
    });
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', Uri.parse('$apiUrl/rider/get-validity'));
      request.body = json.encode({
        "mobileno": phoneNumberController.text,
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        print(data);
        print(
            "https://instaport-transactions.vercel.app/user-password/index.html?phone=${phoneNumberController.text.replaceAll(" ", "")}");
        Get.dialog(
          Dialog.fullscreen(
            backgroundColor: Colors.white,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri(
                      "https://instaport-transactions.vercel.app/user-password/index.html?phone=${phoneNumberController.text.replaceAll(" ", "")}"),
                ),
                shouldOverrideUrlLoading: (controller, request) async {
                  return NavigationActionPolicy.ALLOW;
                },
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    supportZoom: false,
                    clearCache: true,
                    javaScriptEnabled: true,
                    javaScriptCanOpenWindowsAutomatically: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                  android: AndroidInAppWebViewOptions(
                    mixedContentMode:
                        AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                    thirdPartyCookiesEnabled: true,
                  ),
                  ios: IOSInAppWebViewOptions(
                    allowsInlineMediaPlayback: true,
                    allowsAirPlayForMediaPlayback: true,
                    allowsBackForwardNavigationGestures: true,
                    allowsLinkPreview: true,
                    isFraudulentWebsiteWarningEnabled: true,
                    suppressesIncrementalRendering: false,
                  ),
                ),
                onWebViewCreated: (controller) {
                  webView = controller;
                  _setupJavaScriptHandler();
                },
                onLoadStart: (controller, url) {
                  setState(() {});
                },
                onLoadError: (controller, url, code, message) {
                  print("message: $message");
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print("Message: ${consoleMessage.message}");
                },
                onLoadStop: (controller, url) {
                  setState(() {});
                },
              ),
            ),
          ),
          barrierDismissible: false,
        );
      } else {
        var data = await response.stream.bytesToString();
        print(data);
        ToastManager.showToast("No such user exist");
      }
    } catch (e) {
      // _storage.remove("token");
      // Get.to(() => const Login());
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Forgot Password",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Label(label: "Phone Number: "),
            TextFormField(
              inputFormatters: [phoneNumberMask],
              validator: (value) => validatePhoneNumber(value!),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.phone,
              controller: phoneNumberController,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: '+91 00000 00000',
                hintStyle:
                    GoogleFonts.poppins(fontSize: 14, color: Colors.black38),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(width: 2, color: Colors.black26),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(width: 2, color: accentColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: handleVerify,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                height: 50,
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: accentColor,
                ),
                child: loading
                    ? Center(
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          "Verify",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
