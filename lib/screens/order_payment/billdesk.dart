import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:instaport_customer/controllers/user.dart';
import 'package:instaport_customer/models/order_model.dart';
import 'package:instaport_customer/screens/past_orders.dart';
import 'package:instaport_customer/screens/wallet.dart';

class BillDeskPayment extends StatefulWidget {
  final String url;
  final Orders order;

  const BillDeskPayment({super.key, required this.url, required this.order});

  @override
  State<BillDeskPayment> createState() => _BillDeskPaymentState();
}

class _BillDeskPaymentState extends State<BillDeskPayment> {
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
    Get.to(() => const PastOrders());
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
              shouldOverrideUrlLoading: (controller, request) async {
                return NavigationActionPolicy.ALLOW;
              },
              initialSettings: InAppWebViewSettings(
                isInspectable: kDebugMode,
                supportZoom: false,
                clearCache: true,
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsLinkPreview: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                thirdPartyCookiesEnabled: true,
                allowsInlineMediaPlayback: true,
                allowsAirPlayForMediaPlayback: true,
                allowsBackForwardNavigationGestures: true,
                isFraudulentWebsiteWarningEnabled: true,
                suppressesIncrementalRendering: false,
              ),
              onWebViewCreated: (controller) {
                webView = controller;
                _setupJavaScriptHandler();
              },
              onLoadStart: (controller, url) {
                print("STARTED: " + url!.path);
                setState(() {});
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
