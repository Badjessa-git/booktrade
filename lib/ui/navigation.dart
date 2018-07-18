import 'dart:async';

import 'package:flutter/material.dart';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/nav_ui/add_book_ui.dart';
import 'package:booktrade/ui/nav_ui/book_list.dart';

class Navigation extends StatefulWidget {

  TradeApi _api;
  set api(TradeApi api) {
    _api = api;
  }
  dynamic cameras;
  Navigation(TradeApi api, dynamic cameras) {
    _api = api;
    cameras = cameras;
  }

  @override
  _NavigationState createState() => new _NavigationState();

}

class _NavigationState extends State<Navigation> {

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
      appBar: AppBar(
        
        leading: const Icon(Icons.menu),
        title: const Text('BookTrade'),
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.search), 
            onPressed: () {//TODO later
            },  
          ),
          new IconButton(
            icon: const Icon(Icons.library_add),
            onPressed: () {
              dynamic isbn;
              SimpleDialog alert = new SimpleDialog(
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
                          Navigator.push<MaterialPageRoute>(context,
                                    MaterialPageRoute(builder: (context) => new AddBook(book, widget.cameras)));
                        },
                      ),
                      const  Divider(
                        indent: 20.0,
                      ),
                      new RaisedButton(
                        child: const Text('Manual Entry'),
                        onPressed: () {
                          Navigator.push<MaterialPageRoute>(context, 
                                    MaterialPageRoute(builder: (context) => new AddBook(null, widget.cameras)));
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
      ),
      body: TabBarView(
        children: <Widget>[
          new BookList(widget._api),
          const Icon(Icons.local_library),       
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

