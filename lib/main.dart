import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/ui/home.dart';
import 'package:flutter/services.dart';

List<CameraDescription> cameras;

Future<dynamic> main() async {
  cameras = await availableCameras();
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp])
  .then<dynamic>((_){
    runApp(new BookTrade());
  });
}


class BookTrade extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primaryColor: const Color(0xFF48A9A6),
        accentColor: Colors.redAccent,
      ),
      home: new Home(cameras)
    );
  }
}