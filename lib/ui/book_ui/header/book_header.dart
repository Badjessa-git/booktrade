import 'dart:async';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/models/constants.dart';
import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/book_ui/add_book_ui.dart';
import 'package:booktrade/ui/chat_ui/message_ui.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookDetailHeader extends StatefulWidget {
  const BookDetailHeader(this.book, this.bookTag, this._api, this.wishlist,
      {this.cameras});
  final Book book;
  final Object bookTag;
  final TradeApi _api;
  final dynamic cameras;
  final bool wishlist;

  @override
  _BookDetailHeaderScreen createState() => new _BookDetailHeaderScreen();
}

class _BookDetailHeaderScreen extends State<BookDetailHeader> {
  String chatroomID;
  User user;
  bool state;
  bool wishlist;
  BannerAd bannerAd;

  @override
  void initState() {
    setState(() {
      state = widget.book.sold;
      wishlist = widget.wishlist;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dynamic theme = Theme.of(context);
    final dynamic textTheme = theme.textTheme;
    final dynamic deleteBook = Theme.of(context).platform ==
            TargetPlatform.android
        ? new AlertDialog(
            title: const Text('Delete book'),
            content: const Text('Are you sure you want to delete this book'),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context, true)),
              new FlatButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              )
            ],
          )
        : new CupertinoAlertDialog(
            title: const Text('Delete book'),
            content: const Text('Are you sure you want to delete this book'),
            actions: <Widget>[
                new CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context, true)),
                new CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, false))
              ]);

    final dynamic reportContent =
        Theme.of(context).platform == TargetPlatform.android
            ? new AlertDialog(
                title: const Text('Report Content'),
                content: const Text('Do you want to report this book?'),
                actions: <Widget>[
                  new FlatButton(
                      child: const Text('Yes'),
                      onPressed: () => Navigator.pop(context, true)),
                  new FlatButton(
                    child: const Text('No'),
                    onPressed: () => Navigator.pop(context, false),
                  )
                ],
              )
            : new CupertinoAlertDialog(
                title: const Text('Delete book'),
                content: const Text('Do you want to report this book?'),
                actions: <Widget>[
                    new CupertinoButton(
                        child: const Text('Yes'),
                        onPressed: () => Navigator.pop(context, true)),
                    new CupertinoButton(
                        child: const Text('No'),
                        onPressed: () => Navigator.pop(context, false))
                  ]);

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
          ]),
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
              color: state ? Colors.grey : Theme.of(context).accentColor,
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
                } else {
                  await widget._api
                      .updateBook(widget.book, sold: true)
                      .then((_) {
                    setState(() {
                      state = true;
                    });
                  }).catchError((dynamic _) {
                    final SnackBar errorMessage = new SnackBar(
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                        content:
                            const Text('Error Communicating with the Server'));
                    Scaffold.of(context).showSnackBar(errorMessage);
                  });
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
              onPressed: () async {
                if (isAdShown && !calledDisposed) {
                  bannerAd = banner;
                  await bannerAd?.dispose();
                  isAdShown = false;
                  calledDisposed = true;
                }
                Navigator.push<dynamic>(
                    context,
                    new MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) =>
                            AddBook(widget.book, widget.cameras, widget._api)));
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
                if (isAdShown && !calledDisposed) {
                  bannerAd = banner;
                  await bannerAd?.dispose();
                  isAdShown = false;
                  calledDisposed = true;
                }
                await _findReceiverAndChatroom();
                Navigator.push<MaterialPageRoute<dynamic>>(
                    context,
                    new MaterialPageRoute<MaterialPageRoute<dynamic>>(
                        builder: (BuildContext context) => new MessageScreen(
                            widget._api, user, chatroomID,
                            fromBookDetails: true)));
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
                if (!wishlist) {
                  _showSnackbar(5, 'Adding Book to Wishlist', true);
                  await widget._api
                      .addToWishList(widget.book)
                      .then<dynamic>((_) {
                    _showSnackbar(2, 'Success', false);
                  setState(() {
                    wishlist = !wishlist;
                  });
                  }).catchError((dynamic _) => _showSnackbar(
                          4, 'Error Communicating with Server', false));
                } else {
                  await removeBook(context, wishlist, deleteBook);
                }
              },
              child: !wishlist ? const Text('Add to WishList') : const Text('Discard'),
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
          child: const BackButton(
            color: Colors.white,
          ),
        ),
        topRightWidgets(deleteBook, reportContent),
      ],
    );
  }

  dynamic _showSnackbar(int length, String message, bool isloading) {
    return Scaffold.of(context).showSnackBar(new SnackBar(
          duration: new Duration(seconds: length),
          content: new Row(
              children: isloading
                  ? <Widget>[
                      const CircularProgressIndicator(),
                      new Text('  $message')
                    ]
                  : <Widget>[
                      new Text('$message'),
                    ]),
        ));
  }

  Future<void> _findReceiverAndChatroom() async {
    final User _user = await widget._api.getUser(widget.book.sellerUID);
    final String _chatroomID =
        await widget._api.getorCreateChatRomms(widget.book.sellerUID);
    setState(() {
      chatroomID = _chatroomID;
      user = _user;
    });
  }

  dynamic topRightWidgets(dynamic deleteBook, dynamic reportContent) {
    if (widget._api.firebaseUser.uid == widget.book.sellerUID) {
      return Positioned(
        top: 26.0,
        right: 4.0,
        child: new IconButton(
          icon: const Icon(Icons.delete, color: Colors.white),
          onPressed: () async {
            await removeBook(context, false, deleteBook);
          },
        ),
      );
    } else {
      return new Positioned(
            top: 26.0,
            right: 4.0,
            child: new IconButton(
              icon: const Icon(Icons.report,
              color: Colors.white),
            onPressed: () async {
              await reportBook(context, reportContent);
              },
            ),
          );
    }
  }

  dynamic removeBook(
      BuildContext context, bool wishlist, dynamic deleteBook) async {
    final bool val = await showDialog<dynamic>(
        context: context, builder: (BuildContext context) => deleteBook);
    if (wishlist) {
      if (val) {
        _showSnackbar(4, 'Removing book...', true);
        await widget._api.removeFromWishList(widget.book).then((Null _) {
          _showSnackbar(2, 'Success', false);
            setState(() {
                    wishlist = !wishlist;
              });
          Navigator.pushNamedAndRemoveUntil(context, '/Wishlist', ModalRoute.withName('/Navigation'));
        }).catchError(
            () => _showSnackbar(4, 'Server Error, Try again Later', false));
      }
    } else {
      if (val) {
        _showSnackbar(4, 'Removing book...', true);
        await widget._api.deleteBook(widget.book).then<void>((_) {}).catchError(
            () => _showSnackbar(4, 'Server Error, Try again Later', false));
        _showSnackbar(2, '!Scuccess', false);
        Navigator.popAndPushNamed(context, '/Navigation');
      }
    }
  }

  dynamic reportBook(BuildContext context, dynamic reportContent) async {
    final bool val = await showDialog<dynamic>(
        context: context, builder: (BuildContext context) => reportContent);
    if (val) {
      //Send a signal to the back end that a book has been reported
      await widget._api
          .reportBook(widget.book, widget.wishlist)
          .then<void>((void _) => _showSnackbar(2, 'Report received', false))
          .catchError((void _) => _showSnackbar(
              2, 'Error communicating to server, try again', false));
    }
  }
}
