import 'dart:async';
import 'dart:io';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/chat_ui/chatmessage_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class MessageScreen extends StatefulWidget {
  final TradeApi _api;
  final String chatRoomID;
  final User receiver;

  const MessageScreen(this._api, this.receiver, this.chatRoomID);
  @override
  _MessageScreenState createState() => _MessageScreenState();

}

class _MessageScreenState extends State<MessageScreen> with TickerProviderStateMixin {
  final CollectionReference chatRoomRef = Firestore.instance.collection('chatrooms');
  final TextEditingController _textEditingController = new TextEditingController();
  bool _isComposingMessage = false;
  User receiver;
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() { 
    super.initState();
    receiver = widget.receiver;
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: -1.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.ease
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
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
        leading: new IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new StreamBuilder<QuerySnapshot> (
                stream: chatRoomRef.document(widget.chatRoomID).collection('messages')
                                   .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  return snapshot.hasData ? ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new ChatMessageListItem(
                        context: context,
                        index: index,
                        animation: _animation,
                        reference: snapshot,
                      );
                    }
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
                  messageText: null, imageUrl: imgUrl, chatroomID: widget.chatRoomID, time: timestamp
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
    await widget._api.sendMessage(messageText: text, imageUrl: null, chatroomID: widget.chatRoomID, time: timestamp);
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
