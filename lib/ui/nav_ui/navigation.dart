import 'dart:async';
import 'package:booktrade/ui/nav_ui/book_sel_list.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:booktrade/ui/book_ui/add_book_ui.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/nav_ui/book_list.dart';

class Navigation extends StatefulWidget {

  final TradeApi _api;
  final dynamic cameras;

  const Navigation(this._api, this.cameras); 

  @override
  _NavigationState createState() => new _NavigationState();

}

class _NavigationState extends State<Navigation> {
  SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  _NavigationState() {
    searchBar = new SearchBar(
      inBar: false,
      setState: setState,
      onSubmitted: null,
      buildDefaultAppBar: buildAppBar
    );    
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: const Text('BookTrade'),
        actions: <Widget>[
          searchBar.getSearchAction(context),
          new IconButton(
            icon: const Icon(Icons.library_add),
            onPressed: () {
              dynamic isbn;
              final SimpleDialog alert = new SimpleDialog(
                contentPadding: const EdgeInsets.all(20.0),
                children: <Widget> [
                  new TextFormField(
                    key: isbn,
                    decoration: const InputDecoration(
                      hintText: 'Look up book ISBN here', 
                    ),
                  ),
                  const Divider(
                    height: 20.0
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new RaisedButton(
                        child: const Text('Look up'),
                        onPressed: () {
                          final dynamic book = lookup(isbn);
                          Navigator.push<MaterialPageRoute<dynamic>>(context,
                                    MaterialPageRoute<MaterialPageRoute<dynamic>>(builder: (BuildContext context) => new AddBook(book, widget.cameras, widget._api)));
                        },
                      ),
                      const  Divider(
                        indent: 20.0,
                      ),
                      new RaisedButton(
                        child: const Text('Manual Entry'),
                        onPressed: () {
                          Navigator.push<MaterialPageRoute<dynamic>>(context, 
                                    MaterialPageRoute<MaterialPageRoute<dynamic>>(builder: (BuildContext context) => new AddBook(null, widget.cameras, widget._api)));
                        },
                      ),
                    ],
                  ),
                ],
              );
              showDialog<SimpleDialog>(context: context, builder: (_) => alert);
            },
          ),
          
        ],
        bottom : const TabBar(
          indicatorColor : Colors.red,
          tabs : <Widget> [
            const Tab(
              text: 'Buying',
              icon: Icon(Icons.library_books),
            ),
            const Tab(
              text: 'Selling',
              icon: Icon(Icons.local_library),
            )
          ]
        ),
      );
  }
  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
      key: _scaffoldKey,
      appBar: searchBar.build(this.context),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              currentAccountPicture: new GestureDetector(
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(widget._api.firebaseUser.photoUrl),
                ),
              ),
              accountName: new Text(widget._api.firebaseUser.displayName),
              accountEmail: new Text(widget._api.firebaseUser.email),
               decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new NetworkImage("https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg"),
                  fit: BoxFit.fill
                )
              ),
            ),
            const ListTile(
              title: const Text('Chats'),
              leading: const Icon(Icons.chat),
            ),
            const ListTile(
              title: const Text('Profile'),
              leading: const Icon(Icons.person),
            ),
            const ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings),
            ),
            new Divider(
              height: MediaQuery.of(context).size.height - 480.0,
            ),
            new RaisedButton(
              color: Colors.red,
              child: const Text('Log out'),
              onPressed:  () async {
                await TradeApi.siginOutWithGoogle();
                Navigator.of(context).pushReplacementNamed('/');
              },
            )
          ],
        )
      ),
      body: TabBarView(
        children: <Widget>[
          new BookList(widget._api),
          new SellList(widget._api),       
          ],
        ),
      ),
  );
}


  Future<Book> lookup(dynamic isbn) async {
    final Book book = await TradeApi.lookup(isbn, widget._api);
    return book;
  }
}

