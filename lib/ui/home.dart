import 'dart:async';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/ui/nav_ui/navigation.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Home extends StatefulWidget {
  final dynamic cameras;
  
  const Home(this.cameras);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {

  final GlobalKey<FormState> _loginKey = new GlobalKey<FormState>();

  bool _inAsyncCall = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold (
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
              _inAsyncCall = true;
              TradeApi.signInWithGoogle()
                      .then((TradeApi api) => _domainCheck(api))
                      .catchError((dynamic e) => showDialog<AlertDialog>(context: context, builder: (_) => alert));

            },
            icon: const Icon(const IconData(0xe900, fontFamily: 'icomoon')), 
            label:   const Text('Google Sign In',
            style: const TextStyle(
            color: Colors.white,
            ) ,
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
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context)
        )
      ],
    );
    final List<Book> books = await api.getAllBook()
      .then((List<Book> onValue) {
        onValue = null;
        _nextNaviagtion(api);
      })
      .catchError((dynamic onError) async {
        showDialog<AlertDialog>(context: context, builder: (_) => alert);
        await TradeApi.siginOutWithGoogle();
      }
      );
  
  }

  void _nextNaviagtion(TradeApi api) {
      Navigator.push<MaterialPageRoute<dynamic>>(
          context,
            MaterialPageRoute<MaterialPageRoute<dynamic>>(builder: (BuildContext context) => Navigation(api, widget.cameras)),    
      );
  }
}
