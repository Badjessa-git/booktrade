import 'package:flutter/material.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/navigation.dart';

class Home extends StatefulWidget {
  var cameras;
  Home(this.cameras);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      backgroundColor: Colors.lightGreen,
      body: new Container(
      padding: new EdgeInsets.all(20.0),
      child: _siginInPage(context),
    ),
  );

  }

  Widget _siginInPage(BuildContext context) {
    var alert = new AlertDialog(
      title: new Text("Error"),
      content: new Text("Error Signing in"),
    );
    return new Container(
      margin: const EdgeInsets.fromLTRB(
        20.0, 70.0, 20.0, 0.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text("BookTrade",
          style: new TextStyle(
            color: Colors.white,
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
          ),
          ),
          new Divider(
            height: 20.0,
          ),
          new RaisedButton.icon(
            color: Colors.red,
            onPressed: () => TradeApi.signInWithGoogle()
                            .then((TradeApi api) =>  Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Navigation(api, widget.cameras)),
                                  ))
                            .catchError((e) => showDialog(context: context, builder: (_) => alert)
                            ),
            icon: new Icon(const IconData(0xe900, fontFamily: 'icomoon')), 
            label:   new Text("Google Sign In",
            style: new TextStyle(
            color: Colors.white,
            ) ,
            ),
          ),
        ],
      ),
    );
  }
}
