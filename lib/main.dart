import 'package:flutter/material.dart';
import 'package:xkcd/screens/home.dart';

void main() {
  runApp(XkcdApp());
}

class XkcdApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xkcd',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'xkcd navigator'),
    );
  }
}
