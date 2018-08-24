import 'package:booktrade/models/user.dart';
import 'package:booktrade/ui/chat_ui/chat_ui.dart';
import 'package:booktrade/ui/nav_ui/book_list_found.dart';
import 'package:booktrade/ui/nav_ui/book_sel_list.dart';
import 'package:booktrade/ui/settings_ui/settings_app.dart';
import 'package:booktrade/ui/wishlist_ui/wishlist_page.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:booktrade/ui/flutter-search-bar/flutter_search_bar_base.dart';
import 'package:booktrade/ui/book_ui/add_book_ui.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/nav_ui/book_list.dart';
import 'package:booktrade/models/constants.dart';

class Navigation extends StatefulWidget {
  final TradeApi _api;
  final dynamic cameras;

  const Navigation(this._api, this.cameras);

  @override
  _NavigationState createState() => new _NavigationState();
}

class _NavigationState extends State<Navigation>
    with SingleTickerProviderStateMixin {
  int _isbn;
  User _user;
  SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController controller = new TextEditingController();
  TabController _controller;
  List<Tab> _tabList;
  List<Widget> _tabPages;
  List<Book> _searchBooks = <Book>[];
  List<BookListFound> _bookFound = <BookListFound>[];
  String _search;
  BannerAd _bannerAd;
  bool isSeaching = false;

  _NavigationState() {
    searchBar = new SearchBar(
      controller: controller,
      inBar: false,
      setState: setState,
      onSubmitted: onSubmit,
      onChanged: onChange,
      buildDefaultAppBar: buildAppBar,
      hintText: 'Search Book',
      closeOnSubmit: false,
      clearOnSubmit: true,
      onClosed: onClosed,
    );
  }

  void onSubmit(String value) {
    setState(() {
      _search = value;
    });
    searchBook(value, true);
  }

  void onChange(String value) {
    setState(() {
      _search = value;
    });
    searchBook(value, false);
  }

  void searchBook(String value, bool submit) {
    final int curTab = _controller.index;
    switch (curTab) {
      case 0:
        setState(() {
          _searchBooks = sellBooks;
        });
        break;
      case 1:
        setState(() {
          _searchBooks = userSellBooks;
        });
        break;
    }

    final List<BookListFound> bookFound = _buildSearchList();
    setState(() {
      _bookFound = bookFound;
      isSeaching = searchBar.isSearching.value;
    });
    loadTabpages();
    if (submit) {
      searchBar.setState(() {
        controller.clear();
      });
    }
  }

  double smartHeight() {
    final double height = _bannerAd.size.height.toDouble();
    setState(() {});
    return height;
  }

  List<Widget> fakeBottomButtons() {
    return <Widget>[
      new Container(
        height: 30.0,
        decoration: const BoxDecoration(
          color: const Color(0xFFD4B484),
        ),
      )
    ];
  }

  List<BookListFound> _buildSearchList() {
    if (_search.isEmpty) {
      return _searchBooks
          .map((Book curBook) =>
              new BookListFound(widget._api, widget.cameras, curBook))
          .toList();
    } else {
      final List<Book> _searchList = <Book>[];

      for (int i = 0; i < _searchBooks.length; i++) {
        final String title = _searchBooks[i].title;
        if (title.toLowerCase().contains(_search.toLowerCase())) {
          _searchList.add(_searchBooks[i]);
        }
      }
      return _searchList
          .map((Book curBook) =>
              new BookListFound(widget._api, widget.cameras, curBook))
          .toList();
    }
  }

  @override
  void initState() {
    _bannerAd = TradeApi.createBannerAd()
      ..load()
      ..show().catchError(() => print('Error loading add'));
    banner = _bannerAd;
    super.initState();
    _tabList = <Tab>[
      const Tab(
        text: 'Buying',
        icon: Icon(Icons.library_books),
      ),
      const Tab(
        text: 'Selling',
        icon: Icon(Icons.local_library),
      )
    ];

    loadTabpages();
    _controller = new TabController(
      length: _tabList.length,
      vsync: this,
    );
    setState(() {
      isSeaching = searchBar.isSearching.value;
    });
    getUser();
  }

  void loadTabpages() {
    _tabPages = isSeaching
        ? <Widget>[
            new Scaffold(
              backgroundColor: const Color(0xFFD4B484),
              body: new Flex(
                children: <Widget>[
                  new Flexible(
                    child: new ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: _bookFound,
                    ),
                  ),
                ],
                direction: Axis.vertical,
              ),
            ),
            new Scaffold(
              backgroundColor: const Color(0xFFD4B484),
              body: new Flex(
                children: <Widget>[
                  new Flexible(
                    child: new ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: _bookFound,
                    ),
                  ),
                ],
                direction: Axis.vertical,
              ),
            )
          ]
        : <Widget>[
            new BookList(widget._api, widget.cameras),
            new SellList(widget._api, widget.cameras)
          ];
  }

  dynamic getUser() async {
    final User user = await widget._api.getUser(widget._api.firebaseUser.uid);
    setState(() {
      _user = user;
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _controller.dispose();
    super.dispose();
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text('BookTrade'),
      actions: <Widget>[
        searchBar.getSearchAction(context),
        new IconButton(
          icon: const Icon(Icons.library_add),
          onPressed: () {
            final SimpleDialog alert = new SimpleDialog(
              contentPadding: const EdgeInsets.all(20.0),
              children: <Widget>[
                new TextField(
                  controller: controller,
                  onChanged: (String val) => _isbn = int.parse(val),
                  decoration: const InputDecoration(
                    labelText: 'ISBN number',
                    hintText: 'Look up book ISBN here',
                  ),
                ),
                const Divider(height: 20.0),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new RaisedButton(
                        child: const Text('Look up'),
                        onPressed: () {
                          if (_isbn != null) {
                            lookup();
                          }
                        }),
                    const Divider(
                      indent: 20.0,
                    ),
                    new RaisedButton(
                      child: const Text('Manual Entry'),
                      onPressed: () async {
                        if (isAdShown && !calledDisposed) {
                          _bannerAd = banner;
                          await _bannerAd?.dispose();
                          isAdShown = false;
                          calledDisposed = true;
                        }
                        Navigator.push<MaterialPageRoute<dynamic>>(
                            context,
                            MaterialPageRoute<MaterialPageRoute<dynamic>>(
                                builder: (BuildContext context) => new AddBook(
                                    null, widget.cameras, widget._api)));
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
      bottom: new TabBar(
        controller: _controller,
        indicatorColor: Colors.red,
        tabs: _tabList,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: searchBar.build(this.context),
      drawer: new Drawer(
          child: new ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          new UserAccountsDrawerHeader(
            currentAccountPicture: new GestureDetector(
              child: new CircleAvatar(
                backgroundImage:
                    new NetworkImage(widget._api.firebaseUser.photoUrl),
              ),
            ),
            accountName: new Text(widget._api.firebaseUser.displayName),
            accountEmail: new Text(widget._api.firebaseUser.email),
            decoration: new BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          new ListTile(
            title: const Text('Chats'),
            leading: const Icon(Icons.chat),
            onTap: () async {
              if (isAdShown && !calledDisposed) {
                _bannerAd = banner;
                await _bannerAd.dispose();
                isAdShown = false;
                calledDisposed = true;
              }
              Navigator.push<MaterialPageRoute<dynamic>>(
                  context,
                  MaterialPageRoute<MaterialPageRoute<dynamic>>(
                      builder: (BuildContext context) =>
                          new ChatScreen(widget._api)));
            },
          ),
          new ListTile(
              title: const Text('Wishlist'),
              leading: const Icon(Icons.book),
              onTap: () {
                Navigator.of(context).push<MaterialPageRoute<dynamic>>(
                    new MaterialPageRoute<MaterialPageRoute<dynamic>>(
                        builder: (BuildContext context) =>
                            new WishList(_user, widget._api)));
              }),
          new ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.of(context).push<MaterialPageRoute<dynamic>>(
                  new MaterialPageRoute<MaterialPageRoute<dynamic>>(
                      builder: (BuildContext context) =>
                          new Settings(_user, widget._api)));
            },
          ),
        ],
      )),
      body: TabBarView(controller: _controller, children: _tabPages),
      persistentFooterButtons: isAdShown ? fakeBottomButtons() : null,
    );
  }

  dynamic lookup() async {
    await TradeApi.lookup(_isbn, widget._api).then((Book book) async {
      if (isAdShown && !calledDisposed) {
        _bannerAd = banner;
        await _bannerAd.dispose();
        isAdShown = false;
        calledDisposed = true;
      }
      Navigator.push<MaterialPageRoute<dynamic>>(
          context,
          MaterialPageRoute<MaterialPageRoute<dynamic>>(
              builder: (BuildContext context) =>
                  new AddBook(book, widget.cameras, widget._api)));
    }).catchError((dynamic e) {
      final dynamic alert = new AlertDialog(
        title: const Text('Error'),
        content: const Text('An error occured while searching for the book\n'
            'Try again or Input values manually'),
        actions: <Widget>[
          new FlatButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      );
      showDialog<AlertDialog>(context: context, builder: (_) => alert);
      return;
    });
  }

  void onClosed() {
    isSeaching = false;
    loadTabpages();
    setState(() {});
  }
}
