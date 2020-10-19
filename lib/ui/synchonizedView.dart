import 'package:flutter/material.dart';

class SynchronizedView extends StatefulWidget {
  final Stream<int> stream;

  SynchronizedView({this.stream});

  @override
  _SynchronizedViewState createState() => _SynchronizedViewState();
}

class _SynchronizedViewState extends State<SynchronizedView> {
  var secondsToDisplay;

  void _updateSeconds(int newSeconds) {
    setState(() {
      secondsToDisplay = newSeconds;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.stream.listen((seconds) {
      _updateSeconds(seconds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      secondsToDisplay.toString(),
      textScaleFactor: 5.0,
    );
  }
}
