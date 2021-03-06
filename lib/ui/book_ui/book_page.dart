import 'package:booktrade/models/book.dart';
import 'package:booktrade/models/constants.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/book_ui/footer/book_footer.dart';
import 'package:booktrade/ui/book_ui/header/book_header.dart';
import 'package:flutter/material.dart';

class BookDetails extends StatefulWidget {
  const BookDetails(this.book, this.bookTag, this._api, this.wishlist,
    {this.cameras});
  final Book book;
  final Object bookTag;
  final TradeApi _api;
  final dynamic cameras;
  final bool wishlist;

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  final dynamic linearGradient = const BoxDecoration(
    gradient: const LinearGradient(
        begin: FractionalOffset.centerRight,
        end: FractionalOffset.bottomLeft,
        colors: const <Color>[
          const Color(0xFF48A9A6),
          Colors.white,
        ]),
  );

  double smartHeight() {
    final double height = banner.size.height.toDouble();
    setState(() {});
    return height;
  }

  List<Widget> fakeBottomButtons() {
    return <Widget>[
    new Container(
      height: smartHeight(),
      decoration: const BoxDecoration(
        color: const Color(0xFFD4B484),
      ),
    )
  ];
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new SingleChildScrollView(
        child: new Container(
          decoration: linearGradient,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new BookDetailHeader(
                widget.book,
                widget.bookTag,
                widget._api,
                widget.wishlist,
                cameras: widget.cameras,
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: new BookDetailBody(widget.book, widget._api),
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: isAdShown ? fakeBottomButtons() : null,
    );
  }
}
