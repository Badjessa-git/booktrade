import 'package:booktrade/ui/nav_ui/navigation.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/services/TradeApi.dart';

class Home extends StatefulWidget {
  final dynamic cameras;
  
  const Home(this.cameras);

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
      backgroundColor: const Color(0xFF48A9A6),
      body: new Container(
      padding: const EdgeInsets.all(20.0),
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
      margin: const EdgeInsets.fromLTRB(
        20.0, 70.0, 20.0, 0.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('BookTrade',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
          ),
          ),
          const Divider(
            height: 20.0,
          ),
          new RaisedButton.icon(
            color: Colors.red,
            onPressed: () => TradeApi.signInWithGoogle()
                            .then((TradeApi api) =>  Navigator.push<MaterialPageRoute<dynamic>>(
                                  context,
                                  MaterialPageRoute<MaterialPageRoute<dynamic>>(builder: (BuildContext context) => Navigation(api, widget.cameras)),
                                  ))
                            .catchError((dynamic e) => showDialog<AlertDialog>(context: context, builder: (_) => alert)
                            ),
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
}
