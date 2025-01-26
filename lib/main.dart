import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:summerschool_tutorial/model_viewer.dart';

final InAppLocalhostServer localhostServer = InAppLocalhostServer();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localhostServer.start();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  FlutterBluePlus.setLogLevel(LogLevel.verbose, color:false);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Flexible(flex: 2, child: ModelViewer()),
            ],
          ),
        ),
      ),
    );
  }
}
