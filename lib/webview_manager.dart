import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewManager {
  final List<InAppWebViewController> webViewController = [];

  static final WebViewManager _instance = WebViewManager._internal();

  factory WebViewManager() {
    return _instance;
  }

  void registerController(InAppWebViewController controller) {
    webViewController.add(controller);
  }

  void evaluateJavascript(source) {
    for (var element in webViewController) {
      element.evaluateJavascript(source: source);
    }
  }

  WebViewManager._internal();
}
