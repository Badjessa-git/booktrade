import 'dart:async';

import 'package:booktrade/ui/book_ui/book_page.dart';
import 'package:booktrade/utils/routes.dart';
import 'package:booktrade/utils/tools.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/services/TradeApi.dart';

class BookList extends StatefulWidget {
  final TradeApi _api;

  const BookList(this._api);
  @override
  _BookListState createState() => new _BookListState();
}
  
class _BookListState extends State<BookList> {
  List<Book> _books = <Book>[];
  @override
  void initState() {
    super.initState();
    _loadFromFirebase();
    _reloadBook();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: const Color(0xFFD4B484),
      body: new Flex(
        children: <Widget>[
            _marketPage(),
        ], direction: Axis.vertical,
      ),
    );
  }

  dynamic _loadFromFirebase() async {
    final List<Book> books = await widget._api.getAllBook();
    setState(() {
          _books = books;
    });
  }

  // dynamic _loadBooks() async {
  //   final String fileData = await DefaultAssetBundle.of(context).loadString('assets/books.json');
  //   setState(() {
  //         _books = TradeApi.booksFromFile(fileData);
  //    });
  // }

  dynamic _reloadBook() async {
    if (widget._api != null) {
      final List<Book> books = await widget._api.getAllBook();
      setState(() {
          _books = books;
      });
    }
  }

  Widget _marketPage() {
    return new Flexible(
      child: _books == null 
      ? const Center(child: const CircularProgressIndicator())
      : new RefreshIndicator(
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
    _reloadBook();
    return new Future<Null>.value();
  }

  Widget _bookProto(BuildContext context, int index) {
    final Book curbook = _books[index];

    return new Container(
      margin: const EdgeInsets.only(top: 5.0),
      child: new Card(
        color: const Color(0xFFE4DFDA),
        child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new ListTile(
            leading: new Hero (
              tag: index,
              child: new SizedBox(
                height: 100.0,
                width: 60.0,
                child: new Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage( 
                      image: new NetworkImage(curbook.picUrl),
                      fit: BoxFit.contain,
                  ),
                ),
              ),  
            ),
          ),
          title: new Text(
            curbook.title,
            style: const TextStyle(fontWeight:  FontWeight.bold),
          ),
          subtitle: new Text(
            curbook.author + '\n' +
            Tools.convertToEdition(curbook.edition) + ' Edition\n' +
            curbook.sellerID,
            maxLines: 10,
            textAlign: TextAlign.left
          ),
          isThreeLine: true,
          dense: false,
          onTap: () => _navigateToNextPage(curbook, index),
          trailing: curbook.buyerID == null
                  ? new Text('\$${curbook.price}',
                    style: const TextStyle(
                      fontSize: 20.0
                    ),
                  )
                  : const Text(
                    'Sold',
                    style: const TextStyle(
                      fontSize: 20.0
                    ),
                  ),
          ),
        ],
      ),
      ),
    );
  }

  void _navigateToNextPage(Book curbook, Object index) {
    Navigator.of(context).push<FadePageRoute<dynamic>>(
      new FadePageRoute<FadePageRoute<dynamic>>(
        builder: (BuildContext c) {
          return new BookDetails(curbook, index, widget._api);
        },
        settings: const RouteSettings(),
      ),
    );
  }
}