import 'dart:async';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/models/user.dart';
import 'package:booktrade/ui/chat_ui/message_ui.dart';
import 'package:booktrade/ui/nav_ui/navigation.dart';
import 'package:booktrade/ui/settings_ui/settings_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:booktrade/models/constants.dart';

class Home extends StatefulWidget {
  final dynamic cameras;
  const Home(this.cameras);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  String token;
  bool _inAsyncCall = false;
  TradeApi _api;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings data) {
      print('Notifications: $data');
    });
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
    firebaseMessaging.getToken().then((String onValue) {
      token = onValue;
      deviceToken = token;
      print('deviceToken = $deviceToken');
    });

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('**state ${state.toString()}');
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.suspending:
        break;
    }
  }

  void _navigateToMessage(Map<String, dynamic> message) async {
    final TradeApi api = _api == null ? await TradeApi.ensureSignIn() : _api;
    final User user = await api.getUser(message['UID']);
    Navigator.push<dynamic>(
        context,
        new MaterialPageRoute<dynamic>(
            settings: const RouteSettings(name: 'Message'),
            builder: (BuildContext context) =>
                new MessageScreen(api, user, message['chatroomID'])));
  }

  void _showMessageDialog(Map<String, dynamic> message) async {
    final dynamic messageDialog = new AlertDialog(
      title: message['title'],
      content: message['body'],
      actions: <Widget>[
        new FlatButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        new FlatButton(
          child: const Text('Open'),
          onPressed: () => _navigateToMessage(message),
        )
      ],
    );

    showDialog<AlertDialog>(
        context: context, builder: (BuildContext context) => messageDialog);
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
    return new Container(
      margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: new Flex(
        direction: Axis.vertical,
        children: <Widget>[
          new Expanded(
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
                    signIn();
                  },
                  icon:
                      const Icon(const IconData(0xe900, fontFamily: 'icomoon')),
                  label: const Text(
                    'Google Sign In',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                  new FlatButton(
                      child: new RichText(
                          textAlign: TextAlign.center,
                          text: new TextSpan(
                            text: 'Terms and Conditions',
                            style: const TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                fontSize: 10.0),
                            recognizer: new TapGestureRecognizer(),
                          )),
                      onPressed: () {
                        Navigator.of(context).push<MaterialPageRoute<dynamic>>(
                                new MaterialPageRoute<
                                    MaterialPageRoute<dynamic>>(
                              builder: (BuildContext context) {
                                return const ShowPolicy(true);
                              },
                              fullscreenDialog: true,
                            ));
                      }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void signIn() async {
    const dynamic alert = const AlertDialog(
      title: const Text('Error'),
      content: const Text('Error Signing in'),
    );
    setState(() {
      _inAsyncCall = true;
    });
    Future<dynamic>.delayed(const Duration(seconds: 2), () {
      TradeApi.signInWithGoogle().then((TradeApi api) {
        setState(() {
          _api = api;
        });
        _domainCheck(api);
      }).catchError((dynamic e) {
        setState(() {
          _inAsyncCall = false;
        });
        TradeApi.signOutWithGoogle();
        showDialog<AlertDialog>(context: context, builder: (_) => alert);
      });
    });
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
      await api.getAllBook().then((List<Book> onValue) async {
      onValue = null;
      final String school = _findSchoolName(api);
      await api
          .addorUpdateUser(schoolName: school)
          .catchError((dynamic onError) => print(onError));
      setState(() {
        _inAsyncCall = false;
      });
      _nextNaviagtion(api);
    }).catchError((dynamic onError) async {
      showDialog<AlertDialog>(context: context, builder: (_) => alert);
      setState(() {
        _inAsyncCall = false;
      });
      await TradeApi.signOutWithGoogle();
    });
  }

  void _nextNaviagtion(TradeApi api) {
    Navigator.push<MaterialPageRoute<dynamic>>(
      context,
      MaterialPageRoute<MaterialPageRoute<dynamic>>(
          settings: const RouteSettings(name: '/Navigation'),
          builder: (BuildContext context) => Navigation(api, widget.cameras)),
    );
  }

  String _findSchoolName(TradeApi api) {
    final String email = api.firebaseUser.email;
    String school;
    if (email.contains('@lehigh.edu')) {
      school = 'Lehigh University';
    } else {
      school = 'Test University';
    }
    return school;
  }
}
