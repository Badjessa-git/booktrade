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
            crossAxisCount: 2,
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
        child: new Container(
          child: new Column(
            children: <Widget>[
              const Divider(height: 10.0,),
              new Card(
              elevation: 5.0,
              child: new SizedBox(
              height: 150.0,
              width: 120.0,
              child: new Container(
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: new NetworkImage(curbook.picUrl),
                    fit: BoxFit.fill
                  )
                ),
               ),
              ),
            ),
            _bookState(curbook),
            ],
          ),
        ),
    );
  }

  Widget _bookState(Book curbook) {
    if (curbook.buyerID != null) {
      return const Text('SOLD',
      style: const TextStyle(
        fontSize: 14.0,
        color: Colors.red,
        fontWeight: FontWeight.bold
      ),
        textAlign: TextAlign.center,
      );
    } else {
      return const Text('');
    }
  }
}