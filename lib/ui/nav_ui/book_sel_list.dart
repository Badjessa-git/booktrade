import 'dart:async';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:flutter/material.dart';

class SellList extends StatefulWidget {

  final TradeApi _api;

  const SellList(this._api);

  @override
  _SellListState createState() => new _SellListState();
}

class _SellListState extends State<SellList> {
  List<Book> _books = <Book>[];

  @override
  void initState() {
    super.initState();
    _loadUserBooksFromFirebase();
  }

  dynamic _loadUserBooksFromFirebase() async {
    final List<Book> books = await widget._api.getUserBook();
    setState(() {
       _books = books;
    });
  }

  dynamic _reloadBook() async {
    if (widget._api != null) {
      final List<Book> books = await widget._api.getUserBook();
      setState(() {
        _books = books;        
      });
    }
  }

  Future<Null> refresh() {
    _reloadBook();
    return new Future<Null>.value();
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

  Widget _marketPage() {
    return new Flexible(
      child:  new RefreshIndicator(
        onRefresh: refresh,
        child: new GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _books.length,
          itemBuilder: _bookProto,
        ),
      ),
    );
  }


  Widget _bookProto(BuildContext context, int index) {
    final Book curbook = _books[index];
    return new GestureDetector(
      child: new Card(
        child: new Container(
          height: 300.0,
          width: 200.0,
          child: new Column(
            children: <Widget>[
              new SizedBox(
              height: 280.0,
              width: 200.0,
              child: new Container(
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: new NetworkImage(curbook.picUrl),
                    fit: BoxFit.contain
                  )
                ),
              ),
            ),
            _bookState(curbook),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookState(Book curbook) {
    if (curbook.buyerID == null || curbook.buyerID.isEmpty) {
      return const Text('Selling',
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center, 
      );
    } else {
      return const Text('Sold',
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}