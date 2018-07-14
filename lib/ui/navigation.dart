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
  var cameras;
  Navigation(TradeApi api, cameras) {
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
              var isbn;
              var alert = new SimpleDialog(
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
                          Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => new AddBook(book, widget.cameras)));
                        },
                      ),
                      new Divider(
                        indent: 20.0,
                      ),
                      new RaisedButton(
                        child: Text("Manual Entry"),
                        onPressed: () {
                          Navigator.push(context, 
                                    MaterialPageRoute(builder: (context) => new AddBook(null, widget.cameras)));
                        },
                      ),
                    ],
                  ),
                ],
              );
              showDialog(context: context, builder: (_) => alert);
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
      body: TabBarView(controller: 
          new TabController(
            length: 2,
            vsync: AnimatedListState(),
         ),
        children: <Widget>[
          new BookList(widget._api),
          Icon(Icons.local_library),       
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () => {},
          child: new CircleAvatar(
            backgroundImage: new NetworkImage(widget._api.firebaseUser.photoUrl),
            radius: 50.0,
          )
        ),
      ),
  );
}


  Future<Book> lookup(isbn) async {
    Book book = await TradeApi.lookup(isbn, widget._api);
    return book;
  }
}

