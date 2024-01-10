import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BillDeskOrderPayment extends StatefulWidget {
  final String url;

  const BillDeskOrderPayment({super.key, required this.url});

  @override
  State<BillDeskOrderPayment> createState() => _BillDeskOrderPaymentState();
}

class _BillDeskOrderPaymentState extends State<BillDeskOrderPayment> {
  InAppWebViewController? webView;
  void _setupJavaScriptHandler() {
    if (webView != null) {
      // Set up JavaScript handler to listen for messages from the WebView
      webView!.addJavaScriptHandler(
        handlerName: 'callFlutterFunction',
        callback: (args) {
          // Handle the function call from WebView
          // Perform actions or call Flutter functions here
          // print("Function called from WebView");
          // _performActionInFlutter();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
    );
  }
}
