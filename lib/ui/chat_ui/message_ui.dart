import 'dart:async';
import 'dart:io';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/chat_ui/chatmessage_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

dynamic _scaffoldContext;

class MessageScreen extends StatefulWidget {

  final TradeApi _api;
  const MessageScreen(this._api);
  @override
  _MessageScreenState createState() => _MessageScreenState();

}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _textEditingController = new TextEditingController();
  bool _isComposingMessage = false;

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('user'),

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
              child: new AnimatedList(
                padding: const EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: _messageBuilder,
              ),
            ),
            const Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).canvasColor),
              child: _buildTextComposer()
            ),
            new Builder(builder: (BuildContext context) {
              _scaffoldContext = context;
              return new Container(width: 0.0, height: 0.0);
            }),
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

  Widget _messageBuilder(BuildContext context, int index, Animation<double> animation){
    return new ChatMessageListItem(

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
                File imageFile = await ImagePicker.pickImage();
                int timestamp = new DateTime.now().millisecondsSinceEpoch;
                //TODO
                await widget._api.sendMessage(
                  messageText: null, imageUrl: null,
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
    setState(() {
      _isComposingMessage = false;      
    });
    await widget._api.sendMessage(messageText: text, imageUrl: null);
  }
}