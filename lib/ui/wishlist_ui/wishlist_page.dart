import 'dart:async';
import 'package:booktrade/models/constants.dart';
import 'package:booktrade/utils/tools.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/book_ui/book_page.dart';
import 'package:booktrade/utils/routes.dart';
import 'package:flutter/material.dart';

class WishList extends StatefulWidget {
  final User user;
  final TradeApi _api;
  const WishList(this.user, this._api);

  @override
  _WishListState createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  List<Book> _books = <Book>[];
  SearchBar searchBar;
  bool _adShown;
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    _adShown = false;
    super.initState();
    _loadWishlistromFirebase();
    _reloadBook();
  }

  List<Widget> fakeBottomButtons() {
    return <Widget> [
      new Container(
        height: 50.0,
      )
    ];
  }

  dynamic _loadWishlistromFirebase() async {
    final List<Book> books = await widget._api.getWishList();
    if (mounted) {
    setState(() {
      _books = books;
    });
    }

  }

  dynamic _reloadBook() async {
    if (widget._api != null) {
      final List<Book> books = await widget._api.getWishList();
      if (mounted) {
        setState(() {
        _books = books;
      });
      }
    }
  }

  Future<Null> refresh() {
    _reloadBook();
    return new Future<Null>.value();
  }

  @override
  Widget build(BuildContext context) {
     return new Scaffold(
        appBar: new AppBar(
          title: const Text('WishList'),
        ),
      backgroundColor: const Color(0xFFD4B484),
      body: new Flex(
        children: <Widget>[
            _marketPage(),
        ], direction: Axis.vertical,
      ),
      persistentFooterButtons: _adShown ? fakeBottomButtons() : null,
    );
  }

  Widget _marketPage() {
    return new Flexible(
      child: _books == null 
      ? const Center(child: const CircularProgressIndicator())
      : new RefreshIndicator(
        onRefresh: refresh,
        child: _books.isNotEmpty
        ? new ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _books.length,
          itemBuilder: _bookProto,
        )
        : const Center(child: const Text('No Books Available',
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),)),
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
          trailing: curbook.sold == false
                  ? new Text('\$${curbook.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0
                    ),
                  )
                  : const Text(
                    'SOLD',
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.red,
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
          return new BookDetails(curbook, index, widget._api, true);
        },
        settings: const RouteSettings(),
      ),
    );
  }
}
