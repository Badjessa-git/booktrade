import 'dart:async';
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

  TextEditingController controller = new TextEditingController();

  _WishListState() {
    searchBar = new SearchBar(
      inBar: false,
      setState: setState,
      onSubmitted: null,
      buildDefaultAppBar: buildAppBar
    );
  }

  AppBar buildAppBar(BuildContext context){
    return new AppBar(
      title: const Text('WishList'),
      actions: <Widget>[
        searchBar.getSearchAction(context),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadWishlistromFirebase();
  }

  dynamic _loadWishlistromFirebase() async {
    final List<Book> books = await widget._api.getWishList();
    setState(() {
      _books = books;
    });
  }

  dynamic _reloadBook() async {
    if (widget._api != null) {
      final List<Book> books = await widget._api.getWishList();
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
    const dynamic delegate = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
    );

    return new Scaffold(
        appBar: searchBar.build(this.context),
        backgroundColor: const Color(0xFFD4B484),
        body: new Flex(
          children: <Widget>[
            new Flexible(
                child: _books == null
                    ? const Center(child: const CircularProgressIndicator())
                    : new RefreshIndicator(
                        onRefresh: refresh,
                        child: _books.isEmpty
                            ? const Center(
                                child: const Text('No books added to Wishlit',
                                    style: const TextStyle(fontSize: 20.0)))
                            : new GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(top: 16.0),
                                gridDelegate: delegate,
                                itemBuilder: bookbuilder,
                                itemCount: _books.length,
                              ),
                      )),
          ],
          direction: Axis.vertical,
        ));
  }

  Widget bookbuilder(BuildContext context, int index) {
    final Book curbook = _books[index];
    return new Container(
      margin: const EdgeInsets.only(top: 5.0),
      child: new GestureDetector(
          child: Card(
            color: const Color(0xFFE4DFA),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Image.network(
                  curbook.picUrl,
                  width: 200.0,
                  height: 200.0,
                ),
                new Text(curbook.title)
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push<FadePageRoute<dynamic>>(
                  new FadePageRoute<FadePageRoute<dynamic>>(
                    builder: (BuildContext c) {
                      return new BookDetails(curbook, index, widget._api);
                    },
                    settings: const RouteSettings(),
                  ),
                );
          }),
    );
  }
}