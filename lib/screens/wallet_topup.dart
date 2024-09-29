// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:instaport_customer/controllers/user.dart';
import 'package:instaport_customer/screens/wallet.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletTopup extends StatefulWidget {
  final String url;
  const WalletTopup({super.key, required this.url});

  @override
  State<WalletTopup> createState() => _WalletTopupState();
}

class _WalletTopupState extends State<WalletTopup> {
  final UserController userController = Get.put(UserController());
  InAppWebViewController? webView;
  String apptoken = "";

  void _setupJavaScriptHandler() {
    if (webView != null) {
      // Set up JavaScript handler to listen for messages from the WebView
      webView!.addJavaScriptHandler(
        handlerName: 'backfunction',
        callback: (args) {
          _performActionInFlutter();
        },
      );
    }
  }

  void _performActionInFlutter() {
    Get.to(() => const Wallet());
  }

  bool isInAppLink(String url) {
    // Define logic to determine whether the link is an in-app link
    // For example, you might allow all links within the same domain
    return url.contains('upi:');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.url),
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                // var url = navigationAction.request.url.toString();

                // if (url.startsWith("upi://pay")) {
                //   try {
                //     Uri intentUri = Uri.parse(url);
                //     if (await canLaunchUrl(intentUri)) {
                //       await launchUrl(intentUri,
                //           mode: LaunchMode.externalApplication);
                //     } else {
                //       // Fallback logic
                //       String? fallbackUrl = Uri.parse(url)
                //           .queryParameters['browser_fallback_url'];
                //       if (fallbackUrl != null) {
                //         controller.loadUrl(
                //             urlRequest: URLRequest(url: WebUri(fallbackUrl)));
                //       }
                //     }
                //     return NavigationActionPolicy.CANCEL;
                //   } catch (e) {
                //     print("Error parsing UPI URL: $e");
                //   }
                // }
                // return NavigationActionPolicy.ALLOW;

                var uri = navigationAction.request.url!;
                print("82 ${uri.scheme}");
                if (![
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about"
                ].contains(uri.scheme)) {
                  // Check if it's a UPI URL
                  bool isUpiUrl = RegExp(r"(upi)", caseSensitive: false)
                      .hasMatch(uri.toString());
                  print("95 $isUpiUrl");
                  if (isUpiUrl) {
                    print("97 $isUpiUrl");
                    if (await canLaunchUrl(uri)) {
                      print("99 $isUpiUrl");
                      // Launch the UPI app
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                      // Cancel the request in WebView
                      return NavigationActionPolicy.CANCEL;
                    }
                  }
                }
                print("108 $uri");

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
              onLoadStart: (controller, url) async {
                setState(() {});
                print("Trying to load: $url");

                // Check if the URL is an external link or in-app link
                // if (isInAppLink(url!.path)) {
                //   if (await canLaunchUrl(Uri.parse(url!.path))) {
                //     await launchUrl(Uri.parse(url!.path),
                //         mode: LaunchMode.externalApplication);
                //   }
                // } else {
                //   // External link: Open it in an external browser
                // }

                if (![
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about"
                ].contains(url!.scheme)) {
                  // Check if it's a UPI URL
                  bool isUpiUrl = RegExp(r"(upi)", caseSensitive: false)
                      .hasMatch(url.toString());
                  print("95 $isUpiUrl");
                  if (isUpiUrl) {
                    print("97 $isUpiUrl");
                    if (await canLaunchUrl(url)) {
                      print("99 $isUpiUrl");
                      // Launch the UPI app
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                      // Cancel the request in WebView
                    }
                  }
                }
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
      ),
    );
  }
}
