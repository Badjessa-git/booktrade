import 'dart:async';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/book_ui/add_book_ui.dart';
import 'package:booktrade/ui/chat_ui/message_ui.dart';
import 'package:flutter/material.dart';

class BookDetailHeader extends StatefulWidget {

  final Book book;
  final Object bookTag;
  final TradeApi _api;
  final dynamic cameras;
  const BookDetailHeader(this.book, this.bookTag, this._api, {this.cameras});

  @override
  _BookDetailHeaderScreen createState() => new _BookDetailHeaderScreen(); 
}

class _BookDetailHeaderScreen extends State<BookDetailHeader> {
  String chatroomID;
  User user;
  bool state;
  
  @override
  void initState() { 
    setState(() {
      state = widget.book.sold;      
    });
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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

    final dynamic actionsButtons2 = new Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new ClipRRect(
            borderRadius: new BorderRadius.circular(30.0),
            child: new MaterialButton(
              minWidth: 140.0,
              color: state
                   ? Colors.grey
                   : Theme.of(context).accentColor,
              textColor: Colors.white,
              onPressed: () async {
                if (state) {
                  final SnackBar warning = new SnackBar(
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {},
                    ),
                    content: const Text('Book already marked'),
                  );
                  Scaffold.of(context).showSnackBar(warning);
                }
              else {
                final bool success = await widget._api.updateBook(widget.book);
                if (!success) {
                    final SnackBar errorMessage = new SnackBar(
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {
                        },
                      ),
                      content: const Text('Error Communicating with the Server')
                    );
                    Scaffold.of(context).showSnackBar(errorMessage);
                } else {
                  setState(() {
                    state = success;                    
                  });
                }
              }
                },
              child: const Text('Mark it Sold'),
            ),
          ),
          new ClipRRect(
            borderRadius: new BorderRadius.circular(30.0),
            child: new MaterialButton(
              minWidth: 140.0,
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              onPressed: () {
                Navigator.push<dynamic>(context, 
                    new MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => AddBook(widget.book, widget.cameras, widget._api)
                      )
                    );
              },
              child: const Text('Edit'),
            ),
          ),
        ],
      ),
    );
    final dynamic actionsButtons1 = new Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new ClipRRect(
            borderRadius: new BorderRadius.circular(30.0),
            child: new MaterialButton(
              minWidth: 140.0,
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              onPressed: () async {
                    print('working');
                    await _findReceiverAndChatroom();
                    Navigator.push<MaterialPageRoute<dynamic>>(context, 
                          new MaterialPageRoute<MaterialPageRoute<dynamic>>(
                            builder: (BuildContext context) => new MessageScreen(widget._api, user, chatroomID) 
                          )
                    );
                },
              child: const Text('Talk to Seller'),
            ),
          ),
          new ClipRRect(
            borderRadius: new BorderRadius.circular(30.0),
            child: new MaterialButton(
              minWidth: 140.0,
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              onPressed: () async {
                _showSnackbar(10, 'Adding Book to Wishlist', true);
                await widget._api.addToWishList(widget.book)
                      .then<dynamic>((_) => _showSnackbar(4, 'Success', false))
                      .catchError((dynamic _) => _showSnackbar(4, 'Error Communicating with Server', false));
                _scaffoldKey.currentState.hideCurrentSnackBar();
              },
              child: const Text('Add to WishList'),
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
              widget.book.sellerUID == widget._api.firebaseUser.uid
              ? actionsButtons2
              : actionsButtons1
            ],
          ),
        ),
        const Positioned(
          top: 26.0,
          left: 4.0,
          child: const BackButton(color: Colors.white,),
        ),
        widget.book.sellerUID == widget._api.firebaseUser.uid
        ? new Positioned(
          top: 26.0,
          right: 4.0,
            child: new IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                _showSnackbar(10, 'Removing book...', true);
                await widget._api.deleteBook(widget.book)
                            .then((_) {
                              _scaffoldKey.currentState.hideCurrentSnackBar();
                              _showSnackbar(2, '!Scuccess', false);
                              Navigator.popAndPushNamed(context, 'Navigtion');
                            })
                            .catchError(() => _showSnackbar(4, 'Server Error, Try again Later', false));
              },
            ),
          )
        : null,
      ],
    );

  }

    dynamic _showSnackbar(int length, String message, bool isloading) {
     return _scaffoldKey.currentState.showSnackBar(
                new SnackBar(
                  duration: new Duration(seconds: length),
                  content: new Row(
                      children: isloading
                      ? <Widget> [
                        const CircularProgressIndicator(),
                        new Text('  $message')
                      ]
                      : <Widget> [
                        new Text('$message'),
                      ]
            ),
         )
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