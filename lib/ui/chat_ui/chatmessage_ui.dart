import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

dynamic currentUserEmail;
dynamic currentChatPairId;
dynamic currentChatPartner;
dynamic currentUserID;

class ChatMessageListItem extends StatelessWidget {
  dynamic messageSnapshot;

  
  @override
  Widget build(BuildContext context){
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(curve: Curves.decelerate),
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          children: currentUserEmail == messageSnapshot['email']
                ? getSentMessageLayout()
                : getReceivedMessageLayout(),
        ),
      ),
    );
  }

  List<Widget> getSentMessageLayout() {
    return <Widget> [
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text(messageSnapshot.value['senderName'],
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),   
            ),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: messageSnapshot.value['imageUrl'] != null
                  ? new Image.network(
                    messageSnapshot.value['imageUrl'],
                    width: 250.0,
              )
              : new Text(messageSnapshot.value['text']),
            ),
          ],
        ),
      ),
      new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(left: 8.0),
            child: new CircleAvatar(
              backgroundImage: new NetworkImage(messageSnapshot.value['senderPhotoUrl']),
            ),
          )
        ],
      ),
    ];
  }

  List<Widget> getReceivedMessageLayout() {
    return <Widget> [
      new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: new CircleAvatar(
              backgroundImage: new NetworkImage(messageSnapshot.value['senderPhotoUrl']),
            ),
          )
        ],
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(messageSnapshot.value['senderName'],
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
                fontWeight: FontWeight.bold
              )
            ),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: messageSnapshot.value['imageUrl'] != null
                  ? new Image.network(
                    messageSnapshot.value['imageUrl'],
                    width: 250.0,
                  )
                  : new Text(messageSnapshot.value['text']),
            )
          ],
        ),
      )
    ];
  }
}