import 'dart:async';
import 'package:booktrade/models/constants.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/nav_ui/navigation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/ui/home.dart';
import 'package:flutter/services.dart';

List<CameraDescription> cameras;

Future<dynamic> main() async {
  cameras = await availableCameras();
  final TradeApi _api = await TradeApi.ensureSignIn();
  SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp]).then<dynamic>((_) {
    runApp(new BookTrade(_api));
  });
}

class BookTrade extends StatefulWidget {
  final TradeApi _api;
  const BookTrade(this._api);

  @override
  _BookTradeState createState() => new _BookTradeState();
}

class _BookTradeState extends State<BookTrade> {
  TradeApi _api;
  Widget home;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      setState(() {
        _api = widget._api;
      });
      _api == null
          ? setState(() {
              home = new Home(cameras);
            })
          : setState(() {
              home = new Navigation(_api, cameras);
            });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      isIos = true;
    }
    return new MaterialApp(
      theme: new ThemeData(
        primaryColor: const Color(0xFF48A9A6),
        accentColor: Colors.redAccent,
      ),
      home: home,
      routes:<String, WidgetBuilder> {
        '/home' : (BuildContext context) => new Home(cameras),
      },
    );
  }
  
}
