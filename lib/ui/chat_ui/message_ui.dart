import 'dart:async';
import 'dart:io';
import 'package:booktrade/models/constants.dart';
import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class MessageScreen extends StatefulWidget {
  final TradeApi _api;
  final String chatRoomID;
  final User receiver;
  final bool fromBookDetails;
  const MessageScreen(this._api, this.receiver, this.chatRoomID, {this.fromBookDetails});
  @override
  _MessageScreenState createState() => _MessageScreenState();

}

class _MessageScreenState extends State<MessageScreen> with TickerProviderStateMixin {
  final CollectionReference chatRoomRef = Firestore.instance.collection('chatrooms');
  final TextEditingController _textEditingController = new TextEditingController();
  final ScrollController _scrollController = new ScrollController();
  bool _isComposingMessage = false;
  User receiver;
  AnimationController _controller;
  String curUserEmail;
  BannerAd bannerAd;
  @override
  void initState() { 
    super.initState();
    receiver = widget.receiver;
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    curUserEmail = widget._api.firebaseUser.email;
    setState(() {});
  }
  
  @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new WillPopScope(
          onWillPop: () {
            if (!isAdShown && calledDisposed && widget.fromBookDetails != null && widget.fromBookDetails) {
              bannerAd = TradeApi.createBannerAd();
              bannerAd..load()..show();
              isAdShown = true;
              calledDisposed = false;
              banner = bannerAd;
            }
            return Future<bool>.value(true);
          },
          child: const BackButton()        
        ),
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          _userImage(),
          const Divider(indent: 10.0,),
          new Text(widget.receiver.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0
          ),
        ),
          ],
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new StreamBuilder<QuerySnapshot> (
                stream: chatRoomRef.document(widget.chatRoomID).collection('messages').orderBy('time', descending: true)
                                   .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  return snapshot.hasData ? new ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    reverse: true,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) => _messageProto(context, snapshot.data.documents[index])
                  ): const CircularProgressIndicator();
                },
              ),
            ),
            const Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).canvasColor),
              child: _buildTextComposer()
            ),   
          ],
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS ?
          new BoxDecoration(
            border: new Border(
              top: new BorderSide(
                color: Colors.grey[200],
              )
            ),
          ): null,
        ),
    );
  }

  Widget _messageProto(BuildContext context, DocumentSnapshot messageSnapshot) {
    final dynamic object = new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
          children: curUserEmail == messageSnapshot.data['email']
                ? getSentMessageLayout(messageSnapshot)
                : getReceivedMessageLayout(messageSnapshot),
          ),
    );
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //         _scrollController.animateTo(
    //           _scrollController.position.maxScrollExtent,
    //           duration: const Duration(milliseconds: 300),
    //           curve: Curves.easeOut,
    //         );
    // });
    return object;
  }

  List<Widget> getSentMessageLayout(DocumentSnapshot messageSnapshot) {
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

  List<Widget> getReceivedMessageLayout(DocumentSnapshot messageSnapshot) {
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

  CupertinoButton getIOSSendButton() {
    return new CupertinoButton(
      child: const Text('Send'),
      onPressed: _isComposingMessage
            ? () => _textMessageSubmitted(_textEditingController.text)
            : null, 
    );
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: const Icon(Icons.send),
      onPressed: _isComposingMessage
            ? () => _textMessageSubmitted(_textEditingController.text)
            : null,
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(
        color: _isComposingMessage
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,  
      ),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                icon: new Icon(
                  Icons.photo_camera,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () async {
                final File imageFile = await ImagePicker.pickImage();
                final int timestamp = new DateTime.now().millisecondsSinceEpoch;
                final String imgUrl = await widget._api.uploadFile(filePath: imageFile.path , isbn: null);
                await widget._api.sendMessage(
                  messageText: null, imageUrl: imgUrl, chatroomID: widget.chatRoomID, time: timestamp, receiverUID: receiver.uid
                );
              },
            ),            
          ),
          new Flexible(
            child: new TextField(
              controller: _textEditingController,
              onChanged: (String messageText) {
                setState(() {
                  _isComposingMessage = messageText.isNotEmpty;                  
                });
              },
              onSubmitted: _textMessageSubmitted,
              decoration: const InputDecoration.collapsed(hintText: 'Send a message'),
            ),
          ),
          new Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Theme.of(context).platform == TargetPlatform.iOS
                ? getIOSSendButton()
                : getDefaultSendButton()
          ),
         ],
        )
      ),
    );
  }

  Future<Null> _textMessageSubmitted(String text) async {
    _textEditingController.clear();
    final int timestamp = new DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _isComposingMessage = false;      
    });
    await widget._api.sendMessage(messageText: text, imageUrl: null, chatroomID: widget.chatRoomID, time: timestamp, receiverUID: receiver.uid);
  }
  
  Widget _userImage() {
  return new Hero(
      tag: 'user avatar',
      child: CircleAvatar(
        backgroundImage: new NetworkImage(receiver.photoUrl),
      )
    ); 
  }
  
}

