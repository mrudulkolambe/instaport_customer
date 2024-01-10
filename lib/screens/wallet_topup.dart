import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:instaport_customer/controllers/user.dart';
import 'package:instaport_customer/screens/wallet.dart';

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
                url: Uri.parse(widget.url),
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
                setState(() {
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                print("Message: ${consoleMessage.message}");
              },
              onLoadStop: (controller, url) {
                setState(() {
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
