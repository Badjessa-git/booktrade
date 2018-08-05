import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ChatMessageListItem extends StatelessWidget {
  final String currentUserEmail;
  final AnimationController animation;
  final DocumentSnapshot messageSnapshot;
  
  const ChatMessageListItem({this.animation, this.messageSnapshot, this.currentUserEmail});

  @override
  Widget build(BuildContext context){
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          children: currentUserEmail == messageSnapshot.data['email']
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
            new Text(messageSnapshot.data['name'],
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),   
            ),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: messageSnapshot.data['imageUrl'] != null
                  ? new Image.network(
                    messageSnapshot.data['imageUrl'],
                    width: 250.0,
              )
              : new Text(messageSnapshot.data['message']),
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
              backgroundImage: new NetworkImage(messageSnapshot.data['userPic']),
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
              backgroundImage: new NetworkImage(messageSnapshot.data['userPic']),
            ),
          )
        ],
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(messageSnapshot.data['name'],
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
                fontWeight: FontWeight.bold
              )
            ),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: messageSnapshot.data['imageUrl'] != null
                  ? new Image.network(
                    messageSnapshot.data['imageUrl'],
                    width: 250.0,
                  )
                  : new Text(messageSnapshot.data['message']),
            )
          ],
        ),
      )
    ];
  }
}