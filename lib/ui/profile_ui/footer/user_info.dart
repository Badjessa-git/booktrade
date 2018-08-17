import 'package:booktrade/models/user.dart';
import 'package:booktrade/models/constants.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatefulWidget {
  final User user;

  const UserInfo(this.user);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildCard(attribute: 'Name', attributeValue: widget.user.displayName),
            _buildCard(attribute: 'Email', attributeValue: widget.user.email),
            _buildCard(attribute: 'Books', attributeValue: bookLength.toString()),
            _buildCard(attribute: 'Chats', attributeValue: chatLength.toString()),
          ],
        ),
      ),
    );
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

