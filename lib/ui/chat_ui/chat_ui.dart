import 'dart:async';
import 'package:booktrade/models/message.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {

  final TradeApi _api;

  const ChatScreen(this._api);
   
  @override
  _ChatScreenState createState() => new _ChatScreenState();

}

class _ChatScreenState extends State<ChatScreen> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Chats'),
      ),
      backgroundColor: Colors.white,
      body: new Flex(
        direction: Axis.vertical,
        children: <Widget>[
          new Flexible(
            child: new RefreshIndicator(
              onRefresh: refresh,
              child: new ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: dummyData.length,
              itemBuilder: _chatProto
              ),
            )
          ),
        ],
      )
    );
  }

  Widget _chatProto(BuildContext context, int index) {
    return new Column(
        children: <Widget>[
         const Divider(
           height: 10.0,
          ),
          new ListTile(
            leading: new CircleAvatar(
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.grey,
            backgroundImage: new NetworkImage(dummyData[index].userPic),
            ),
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
                new Text(
                dummyData[index].name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                new Text(
                dummyData[index].time,
                style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                )
            ],
           ),
          subtitle: new Container(
          padding: const EdgeInsets.only(top: 5.0),
          child: new Text(
            dummyData[index].message,
            style: const TextStyle(color: Colors.grey, fontSize: 15.0),
            ),
          ),
         )
       ],
     );  
    }

  Future<Null> refresh() {
  }
}