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
        primaryColor: const Color(0xFF48A9A6),
        accentColor: Colors.redAccent,
      ),
      home: new SplashScreen(),
      routes: <String, WidgetBuilder> {
        '/Home': (BuildContext context) => new Home(cameras),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  dynamic startTime() async {
    const dynamic _duration = const Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/Home');
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: const Color(0xFF48A9A6),
      body: new Center(
        child: new Image.asset('assets/img/logo.png'),
      ),
    );
  }
}

