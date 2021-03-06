import 'dart:async';
import 'package:booktrade/models/constants.dart';
import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/chat_ui/message_ui.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(this._api);

  final TradeApi _api;

  @override
  _ChatScreenState createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  BannerAd bannerAd;
  List<User> _allUsers = <User>[];
  final Map<User, String> mapOfUsers = <User, String>{};
  @override
  void initState() {
    super.initState();
    _getAllChatrooms();
  }

  dynamic _getAllChatrooms() async {
    final List<String> allChatRoomsID = await widget._api.getAllChatrooms();
    final List<User> otheusers = <User>[];
    for (final String val in allChatRoomsID) {
      final User tempUser = await widget._api.fromChatRoomFirebase(val);
      if (tempUser != null) {
        otheusers.add(tempUser);
        mapOfUsers.putIfAbsent(tempUser, () => val);
      }
    }
    setState(() {
      _allUsers = otheusers;
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          leading: new WillPopScope(
          onWillPop: () {
            if (!isAdShown && calledDisposed) {
              bannerAd = TradeApi.createBannerAd();
              bannerAd..load()..show();
              isAdShown = true;
              calledDisposed = false;
              banner = bannerAd;
            }
            return Future<bool>.value(true);
          },
          child: const BackButton()        
        ),
          title: const Text('Messages'),
        ),
        backgroundColor: Colors.white,
        body: new Flex(
          direction: Axis.vertical,
          children: <Widget>[
            new Flexible(
                child: _allUsers.isEmpty
                    ? const Center(
                        child: const Text('No Messages Available'),
                      )
                    : new RefreshIndicator(
                        onRefresh: refresh,
                        child: new ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _allUsers.length,
                            itemBuilder: _chatProto),
                      )),
          ],
        ));
  }

  Widget _chatProto(BuildContext context, int index) {
    return new Column(
      children: <Widget>[
        const Divider(
          height: 10.0,
        ),
        new ListTile(
          leading: new CircleAvatar(
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey,
              backgroundImage: new NetworkImage(_allUsers[index].photoUrl)),
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                _allUsers[index].displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          enabled: true,
          onTap: () {
            final String chatroom = mapOfUsers[_allUsers[index]];
            Navigator.push<MaterialPageRoute<dynamic>>(
                context,
                MaterialPageRoute<MaterialPageRoute<dynamic>>(
                    builder: (BuildContext context) => new MessageScreen(
                        widget._api, _allUsers[index], chatroom, fromBookDetails: false,)));
          },
        ),
      ],
    );
  }

  Future<Null> refresh() {
    _reloadChats();
    return Future<Null>.value();
  }

  dynamic _reloadChats() async {
    if (widget._api != null) {
      final List<String> allChatRoomsID = await widget._api.getAllChatrooms();
      final List<User> otheusers = <User>[];
      for (final String val in allChatRoomsID) {
        final User tempUser = await widget._api.fromChatRoomFirebase(val);
        if (tempUser != null) {
          otheusers.add(tempUser);
          mapOfUsers.putIfAbsent(tempUser, () => val);
        }
      }
      setState(() {
        _allUsers = otheusers;
      });
    }
  }
}
