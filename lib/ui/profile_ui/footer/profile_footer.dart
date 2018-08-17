import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/profile_ui/footer/user_info.dart';
import 'package:booktrade/ui/profile_ui/footer/wishlist.dart';
import 'package:flutter/material.dart';

class ProfileDetailFooter extends StatefulWidget {
  final User user;
  final TradeApi _api;
  const ProfileDetailFooter(this.user, this._api);

  @override
  _ProfileDetailFooterState createState() => _ProfileDetailFooterState();
}

class _ProfileDetailFooterState extends State<ProfileDetailFooter>
with TickerProviderStateMixin {
  
  List<Tab> _tabList;
  List<Widget> _tabPages;
  TabController _controller;

  @override
  void initState() { 
    _tabList = <Tab> [
      const Tab(text: 'Personal Info'),
      const Tab(text: 'WishList'),
    ];

    _tabPages = <Widget> [
      new UserInfo(widget.user),
      new WishList(widget.user, widget._api),
    ];

    _controller = new TabController(
      length: _tabList.length,
      vsync: this,
    );
    super.initState();
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
          )
        ],
      ),
    ); 
  }
}