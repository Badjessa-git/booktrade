import 'dart:async';

import 'package:booktrade/models/book.dart';
import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/chat_ui/message_ui.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BookDetailHeader extends StatefulWidget {

  final Book book;
  final Object bookTag;
  final TradeApi _api;
  const BookDetailHeader(this.book, this.bookTag, this._api);

  @override
  _BookDetailHeaderScreen createState() => new _BookDetailHeaderScreen(); 
}

class _BookDetailHeaderScreen extends State<BookDetailHeader> {
  String chatroomID;
  User user;

  @override
  Widget build(BuildContext context) {
    final dynamic theme = Theme.of(context);
    final dynamic textTheme = theme.textTheme;

    final dynamic avatar = new Hero(
      tag: widget.bookTag,
      child: new SizedBox(
        width: 200.0,
        height: 200.0,
        child: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new NetworkImage(widget.book.picUrl),
          ),
        ),
        ),
      ),
    );

    final dynamic price = new Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.attach_money,
            color: Colors.white,
            size: 16.0,
            ),
          new Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: new Text(
              widget.book.price.toString(),
              style: textTheme.subhead.copyWith(color: Colors.white),
              ),
            ), 
          ]
        ),
    );

    final dynamic actionsButtons = new Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new ClipRRect(
            borderRadius: new BorderRadius.circular(30.0),
            child: new MaterialButton(
              minWidth: 140.0,
              color: widget.book.sellerUID == widget._api.firebaseUser.uid
                    ? Colors.grey
                    : Theme.of(context).accentColor,
              textColor: Colors.white,
              onPressed: () async {
                  if (widget.book.sellerUID != widget._api.firebaseUser.uid) { 
                    print('working');
                    await _findReceiverAndChatroom();
                    Navigator.push<MaterialPageRoute<dynamic>>(context, 
                          new MaterialPageRoute<MaterialPageRoute<dynamic>>(
                            builder: (BuildContext context) => new MessageScreen(widget._api, user, chatroomID) 
                          )
                        );
                    }
                   else {
                    print('Not working');
                    final SnackBar errorMessage = new SnackBar(
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {
                        },
                      ),
                      content: const Text('Disabled Button')
                    );
                    Scaffold.of(context).showSnackBar(errorMessage);
                  };
                },
              child: const Text('Talk to Seller'),
            ),
          ),
        ],
      ),
    );

    return new Stack(
      children: <Widget>[
        new Align(
          alignment: FractionalOffset.bottomCenter,
          heightFactor: 1.2,
          child: new Column(
            children: <Widget>[
              avatar,
              price,
              actionsButtons,
            ],
          ),
        ),
        const Positioned(
          top: 26.0,
          left: 4.0,
          child: const BackButton(color: Colors.white,),
        )
      ],
    );

  }


    Future<Null> _findReceiverAndChatroom() async {
      final User _user = await widget._api.getUser(widget.book.sellerUID);
      final String _chatroomID = await widget._api.getorCreateChatRomms(widget.book.sellerUID);
      setState(() {
          chatroomID = _chatroomID;
          user = _user;
      });
    }
}