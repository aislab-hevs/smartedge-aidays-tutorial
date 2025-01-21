import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:summerschool_tutorial/webview_manager.dart';

late final InAppWebViewController modelViewerController;

class ModelViewer extends StatelessWidget {
  ModelViewer({
    super.key,
    callback,
  });
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
          url: WebUri(
              "http://localhost:8080/assets/3d/dist/index.html")),
      onWebViewCreated: (controller) {
        WebViewManager().registerController(controller);
      },
      onLoadStart: (controller, url) {},
      onLoadStop: (controller, url) {},
      onConsoleMessage: (controller, consoleMessage) {
        print("CONSOLE: ${consoleMessage.message}");
      },);
  }
}