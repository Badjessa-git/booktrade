import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/ui/home.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  cameras = await availableCameras();
  runApp(new BookTrade());
}


class BookTrade extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primaryColor: Colors.lightGreen,
        accentColor: Colors.redAccent,
      ),
      home: new Home(cameras),
    );
  }
}


