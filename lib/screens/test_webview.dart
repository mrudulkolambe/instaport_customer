import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:instaport_customer/components/getsnackbar.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';

class TestWebView extends StatefulWidget {
  const TestWebView({super.key});

  @override
  State<TestWebView> createState() => _TestWebViewState();
}

class _TestWebViewState extends State<TestWebView> {
  InAppWebViewController? webView;
  bool _isLoading = true;

  void _setupJavaScriptHandler() {
    if (webView != null) {
      // Set up JavaScript handler to listen for messages from the WebView
      webView!.addJavaScriptHandler(
        handlerName: 'callFlutterFunction',
        callback: (args) {
          // Handle the function call from WebView
          // Perform actions or call Flutter functions here
          // print("Function called from WebView");
          _performActionInFlutter();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse(
                    'https://instaport-transactions.vercel.app/?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NTYzMTZiNTdiMzJlMGNlODkxYjk2MzEiLCJyb2xlIjoiY3VzdG9tZXIiLCJpYXQiOjE3MDE2NzIzOTd9.ED4KSGbWiDYKcVQJylXawGYwPZtL9hOvsUhis2tYYEc'),
              ),
              shouldOverrideUrlLoading: (controller, request) async {
                return NavigationActionPolicy.ALLOW;
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  supportZoom: false,
                  clearCache: true,
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically:true,
                  mediaPlaybackRequiresUserGesture: false,
                ),
                android: AndroidInAppWebViewOptions(
                  mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
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
                  _isLoading = true;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // webView.evaluateJavascript(source: source);
        },
        child: const Icon(Icons.call), // Change the icon as needed
      ),
    );
  }

  void _performActionInFlutter() {
    GetSnackbar.info("this is a function called by javascript using webview");
  }
}
