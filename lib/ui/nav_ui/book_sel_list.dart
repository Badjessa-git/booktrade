import 'dart:async';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/models/constants.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/book_ui/book_page.dart';
import 'package:booktrade/utils/routes.dart';
import 'package:booktrade/utils/tools.dart';
import 'package:flutter/material.dart';

class SellList extends StatefulWidget {

  final TradeApi _api;
  final dynamic cameras;
  const SellList(this._api, this.cameras);

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
    bookLength = _books.length;
    return new Flexible(
      child:  new RefreshIndicator(
        onRefresh: refresh,
        child: _books.isNotEmpty
        ? new ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _books.length,
          itemBuilder: _bookProto,
        )
        : const Center(child: const Text('No Books Available',
                       style: const TextStyle(
                         fontSize: 24.0
                       ),),
        ),
      ),
    );
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
          ),
            _bookState(curbook),
            ],
          ),
        ),
    );
  }

  Widget _bookState(Book curbook) {
    if (curbook.sold == true) {
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
    void _navigateToNextPage(Book curbook, Object index) {
    Navigator.of(context).push<FadePageRoute<dynamic>>(
      new FadePageRoute<FadePageRoute<dynamic>>(
        builder: (BuildContext c) {
          return new BookDetails(curbook, index, widget._api, cameras: widget.cameras);
        },
        settings: const RouteSettings(),
      ),
    );
  }
}