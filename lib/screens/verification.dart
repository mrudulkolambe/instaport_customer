// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/main.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/models/user_model.dart';
import 'package:instaport_customer/screens/login.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  var presscount = 0;
  final _storage = GetStorage();
  bool loading = false;

  InAppWebViewController? webView;
  String apptoken = "";

  void _setupJavaScriptHandler() {
    if (webView != null) {
      // Set up JavaScript handler to listen for messages from the WebView
      webView!.addJavaScriptHandler(
        handlerName: 'successVerification',
        callback: (args) {
          _successVerification();
        },
      );
      webView!.addJavaScriptHandler(
        handlerName: 'leaveVerification',
        callback: (args) {
          _leaveVerifcation();
        },
      );
    }
  }

  void _successVerification() {
    Get.back();
    Get.to(() => const SplashScreen());
  }

  void _leaveVerifcation() {
    Get.back();
  }

  void handleVerify() async {
    setState(() {
      loading = true;
    });
    final token = await _storage.read("token");
    if (token.toString() == "" || token == null) {
      Get.to(() => const Login());
    } else {
      try {
        final data = await http.get(Uri.parse('$apiUrl/user/'),
            headers: {'Authorization': 'Bearer $token'});
        final userData = UserDataResponse.fromJson(jsonDecode(data.body));
        if (!userData.user.verified) {
          Get.dialog(
            Dialog.fullscreen(
              backgroundColor: Colors.white,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(
                        "https://instaport-transactions.vercel.app/user-otp/index.html?phone=${userData.user.mobileno.replaceAll(" ", "")}&token=$token"),
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
          _storage.remove("token");
          Get.to(() => const Login());
        }
      } catch (e) {
        // _storage.remove("token");
        // Get.to(() => const Login());
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        presscount++;

        if (presscount == 2) {
          exit(0);
        } else {
          var snackBar = const SnackBar(
              content: Text('press another time to exit from app'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return false;
        }
      },
      child: Scaffold(
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SvgPicture.asset(
                //   "assets/review.svg",
                //   height: MediaQuery.of(context).size.width * 0.5,
                //   width: MediaQuery.of(context).size.width * 0.5,
                // ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Your number is not verified",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Please verify your phone number by clicking the button below",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 15,
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
        )),
      ),
    );
  }
}
