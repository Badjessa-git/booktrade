import 'package:booktrade/models/book.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/book_ui/footer/book_info.dart';
import 'package:booktrade/ui/book_ui/footer/seller_info.dart';
import 'package:flutter/material.dart';

class BookDetailBody extends StatefulWidget {

  final Book book;
  final TradeApi _api;
  const BookDetailBody(this.book, this._api);

  @override
  _BookDetailBodyState createState() => _BookDetailBodyState();
}

class _BookDetailBodyState extends State<BookDetailBody> 
with TickerProviderStateMixin {

  List<Tab> _tabList;
  List<Widget> _tabPages;
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _tabList = <Tab> [
      const Tab(text: 'Details',),
      const Tab(text: 'Seller Info')
    ];

    _tabPages = <Widget> [
      new BookInfo(widget.book),
      new SellerInfo(widget.book, widget._api),
    ];

    _controller = new TabController(
      length: _tabList.length,
      vsync: this,
    );

  }

  @override
  Widget build(BuildContext context) {
      return new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            new TabBar(
              controller: _controller,
              tabs: _tabList,
              indicatorColor: Theme.of(context).accentColor,
            ),
            new SizedBox.fromSize(
              size: const Size.fromHeight(300.0),
              child: new TabBarView(
                controller: _controller,
                children: _tabPages,
              ),
            ),
          ],
        ),
      );
    }
}