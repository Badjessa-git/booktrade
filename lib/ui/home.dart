import 'dart:async';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/models/message.dart';
import 'package:booktrade/ui/nav_ui/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:validator/validator.dart';

final Map<String, Message> _Messages = <String, Message>{};



class Home extends StatefulWidget {
  final dynamic cameras;

  const Home(this.cameras);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  bool _inAsyncCall = false;

  @override
  void initState() {
    super.initState();
    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) {
        print('onLaunch: $message');
        _navigateToMessage(message);
      },
      onResume: (Map<String, dynamic> message) {
        print('onResume: $message');
        _navigateToMessage(message);
      },
      onMessage: (Map<String, dynamic> message) {
        print('onMessage: $message');
        _showMessageDialog(message);
      },
    );
  }

  void _navigateToMessage(Map<String, dynamic> message) {

  }

  void _showMessageDialog(Map<String, dynamic> message) {

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: const Color(0xFF48A9A6),
      body: new ModalProgressHUD(
        inAsyncCall: _inAsyncCall,
        progressIndicator: const CircularProgressIndicator(),
        child: _siginInPage(context),
      ),
    );
  }

  Widget _siginInPage(BuildContext context) {
    const dynamic alert = const AlertDialog(
      title: const Text('Error'),
      content: const Text('Error Signing in'),
    );
    return new Container(
      margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            child: new Image.asset('assets/img/logo.png'),
          ),
          new RaisedButton.icon(
            elevation: 5.0,
            color: Colors.red,
            onPressed: () {
              setState(() {
                _inAsyncCall = true;
              });
              Future<dynamic>.delayed(const Duration(seconds: 2), () {
                TradeApi
                    .signInWithGoogle()
                    .then((TradeApi api) => _domainCheck(api))
                    .catchError((dynamic e) {
                  setState(() {
                    _inAsyncCall = false;
                  });
                  TradeApi.siginOutWithGoogle();
                  showDialog<AlertDialog>(
                      context: context, builder: (_) => alert);
                });
              });
            },
            icon: const Icon(const IconData(0xe900, fontFamily: 'icomoon')),
            label: const Text(
              'Google Sign In',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _domainCheck(TradeApi api) async {
    final dynamic alert = new AlertDialog(
      title: const Text('Error'),
      content: const Text('Your email is not registered with a school domain'),
      actions: <Widget>[
        new FlatButton(
            child: const Text('OK'), onPressed: () => Navigator.pop(context))
      ],
    );
    final List<Book> books =
        await api.getAllBook().then((List<Book> onValue) async {
      onValue = null;
      final String schoolName = _findSchoolName(api);
      await api.pushToUserCollection(schoolName);
      setState(() {
        _inAsyncCall = false;
      });
      _nextNaviagtion(api);
    }).catchError((dynamic onError) async {
      showDialog<AlertDialog>(context: context, builder: (_) => alert);
      setState(() {
        _inAsyncCall = false;
      });
      await TradeApi.siginOutWithGoogle();
    });
  }

  void _nextNaviagtion(TradeApi api) {
    Navigator.push<MaterialPageRoute<dynamic>>(
      context,
      MaterialPageRoute<MaterialPageRoute<dynamic>>(
          builder: (BuildContext context) => Navigation(api, widget.cameras)),
    );
  }

  String _findSchoolName(TradeApi api) {
    String email = api.firebaseUser.email;
    String schoolName;
    if (email.contains('@lehigh.edu')) {
      schoolName = 'Lehigh University';
    } else {
      schoolName = 'Test University';
    }
    return schoolName;
  }
}
