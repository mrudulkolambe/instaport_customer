import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool isInAppLink(String url) {
    // Define logic to determine whether the link is an in-app link
    // For example, you might allow all links within the same domain
    return url.contains('upi:');
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
              url: WebUri(widget.url),
            ),
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var url = navigationAction.request.url.toString();
              print("Trying to load: $url");

              // Check if the URL is an external link or in-app link
              if (url.startsWith('http') || url.startsWith('https')) {
                if (isInAppLink(url)) {
                  // In-app link: Load it within the WebView
                  return NavigationActionPolicy.CANCEL;
                } else {
                  // External link: Open it in an external browser
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                  return NavigationActionPolicy.CANCEL; // Don't load in WebView
                }
              }
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
              print("WebView Created");
              webView = controller;
              _setupJavaScriptHandler();
            },
            onLoadStart: (controller, url) {
              print("Page started loading: $url");
              _handleUrlChange(url.toString());
            },
            onLoadStop: (controller, url) async {
              print("Page finished loading: $url");
              _handleUrlChange(url.toString());
            },
            onUpdateVisitedHistory: (controller, url, isReload) {
              print("URL changed: $url");
              _handleUrlChange(url.toString());
            },
          ),
        ),
      ),
    );
  }

  void _handleUrlChange(String url) {
    // Trigger your event or action here
    if (url.startsWith('upi://')) {
      print(url);
      // Handle UPI payment URL
      _launchUPI(url);
    } else {
      // Handle other URL changes
      print('URL changed to: $url');
    }
  }

  void _launchUPI(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('Could not launch UPI URL: $url');
    }
  }
}
