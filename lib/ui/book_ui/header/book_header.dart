import 'package:booktrade/models/book.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BookDetailHeader extends StatefulWidget {

  final Book book;
  final Object bookTag;

  const BookDetailHeader(this.book, this.bookTag);

  @override
  _BookDetailHeaderScreen createState() => new _BookDetailHeaderScreen(); 
}

class _BookDetailHeaderScreen extends State<BookDetailHeader> {

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
              color: theme.accentColor,
              textColor: Colors.white,
              onPressed: () {

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
}