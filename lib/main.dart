import 'dart:io';
import 'dart:io' show Platform;

import 'package:Youtility/ui/content.dart';
import 'package:Youtility/utils/logMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:window_size/window_size.dart';

void main() {
  updateLogMessage("Starting Youtility...");
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(Size(820, 600));
  }
  runApp(
    Youtility(),
  );
}

class Youtility extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Youtility',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      home: Phoenix(child: MainPage(title: 'Youtility')),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Content();
  }
}
