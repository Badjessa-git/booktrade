import 'dart:async';

import 'package:flutter/material.dart';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/services/TradeApi.dart';

class BookList extends StatefulWidget {
  static TradeApi _api;
  BookList(TradeApi api) {
    _api = api;
  }  
  @override
  _BookListState createState() => new _BookListState();
}
  
class _BookListState extends State<BookList> {
  List<Book> _books = [];
  var curUser = BookList._api.firebaseUser;
  @override
  void initState() {
    super.initState();
    _loadBooks();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey,
      body: new Flex(
        children: <Widget>[
            _marketPage(),
        ], direction: Axis.vertical,
      ),
    );
  }

  _loadBooks() async {
    String fileData = await DefaultAssetBundle.of(context).loadString("assets/books.json");
    setState(() {
          _books = TradeApi.booksFromFile(fileData);
     });
  }

  Widget _marketPage() {
    //TODO implement later
    return new Flexible(
      child: new RefreshIndicator(
        onRefresh: refresh,
        child: new ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _books.length,
          itemBuilder: _bookProto,
        ),
      ),
    );
  }


  Future<Null> refresh() {
    _loadBooks();
    return new Future<Null>.value();
  }

  Widget _bookProto(BuildContext context, int index) {
    Book curbook = _books[index];

    return new Container(
      margin: const EdgeInsets.only(top: 5.0),
      child: new Card(
        color: Colors.brown,
        child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new ListTile(
            leading: new Hero (
              tag: index,
              child: new Image.network(
                curbook.picUrl,
                fit: BoxFit.contain,
                height: 100.0,
                width: 60.0,
              ),
          ),
          title: new Text(
            curbook.title,
            style: new TextStyle(fontWeight:  FontWeight.bold),
          ),
          subtitle: new Text(
            curbook.author + "\n" +
            curbook.edition + "\n" +
            curbook.sellerID,
            maxLines: 10,
            textAlign: TextAlign.left
          ),
          isThreeLine: true,
          dense: false,
          ),
        ],
      ),
      ),
    );
  }
}