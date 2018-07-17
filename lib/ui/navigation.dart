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
    this._api = api;
    this.cameras = cameras;
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
        leading: new Icon(Icons.menu),
        title: new Text("BookTrade"),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.search), 
            onPressed: () {//TODO later
            },  
          ),
          new IconButton(
            icon: Icon(Icons.library_add),
            onPressed: () {
              dynamic isbn;
              SimpleDialog alert = new SimpleDialog(
                contentPadding: EdgeInsets.all(20.0),
                children: <Widget> [
                  new TextFormField(
                    key: isbn,
                    decoration: new InputDecoration(
                      hintText: "Look up book ISBN here", 
                    ),
                  ),
                  new Divider(
                    height: 20.0
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new RaisedButton(
                        child: Text("Look up"),
                        onPressed: () {
                          var book = lookup(isbn);
                          Navigator.push<MaterialPageRoute>(context,
                                    MaterialPageRoute(builder: (context) => new AddBook(book, widget.cameras)));
                        },
                      ),
                      new Divider(
                        indent: 20.0,
                      ),
                      new RaisedButton(
                        child: Text("Manual Entry"),
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
        bottom : TabBar(
          indicatorColor : Colors.red,
          tabs : [
            Tab(
              text: 'Buying',
              icon: Icon(Icons.library_books),
            ),
            Tab(
              text: 'Selling',
              icon: Icon(Icons.local_library),
            )
          ]
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          new BookList(widget._api),
          Icon(Icons.local_library),       
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: null,
          child: new CircleAvatar(
            backgroundImage: new NetworkImage(widget._api.firebaseUser.photoUrl),
            radius: 50.0,
          )
        ),
      ),
  );
}


  Future<Book> lookup(dynamic isbn) async {
    Book book = await TradeApi.lookup(isbn, widget._api);
    return book;
  }
}

