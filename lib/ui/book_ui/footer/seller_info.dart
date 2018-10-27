import 'package:booktrade/models/book.dart';
import 'package:booktrade/models/user.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/services/TradeApi.dart';

class SellerInfo extends StatefulWidget{
  const SellerInfo(this.book, this._api);

  final Book book;
  final TradeApi _api;

  @override
  _SellerInfoState createState() => new _SellerInfoState();

}

class _SellerInfoState extends State<SellerInfo> {
  User _user = new User(
    email: 'loading...',
    displayName: 'loading...',
    school: 'loading...',
    photoUrl: null,
    uid: null,
    deviceToken: null,
    notify: null,
  );
  @override
  void initState() {
      // TODO: implement initState
      _getUser();
      super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: new Center(
        child:new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildCard(attribute: 'Name', attributeValue: _user.displayName),
            _buildCard(attribute: 'Email', attributeValue: _user.email),
            _buildCard(attribute: 'School', attributeValue: _user.school),          
          ],
        ),
      ),
    );
  }

  dynamic _getUser() async {
    if (widget._api != null) {
      final User user = await widget._api.getUser(widget.book.sellerUID);
      setState(() {
        _user = user;         
      });
    }
  }

  Widget _buildCard({String attribute, String attributeValue}) {
    return new Card(
      margin: const EdgeInsets.only(top: 10.0),
      elevation: 5.0,
      child: new SizedBox(
        width: 400.0,
        child: new RichText(
          text: new TextSpan(
            style: const TextStyle(
              height: 1.5,
              fontSize: 20.0,
              color: Colors.black
            ),
            children: <TextSpan> [
              new TextSpan(text: '$attribute: ', style: const TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(text: '$attributeValue')
            ]
          ),
        ),
      ),
    );
  }


}