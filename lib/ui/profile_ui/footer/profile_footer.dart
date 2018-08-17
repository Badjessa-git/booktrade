import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:flutter/material.dart';

class ProfileDetailFooter extends StatefulWidget {
  final User user;
  final TradeApi _api;
  const ProfileDetailFooter(this.user, this._api);

  @override
  _ProfileDetailFooterState createState() => _ProfileDetailFooterState();
}

class _ProfileDetailFooterState extends State<ProfileDetailFooter> {
  @override
  Widget build(BuildContext context) {
    return null; 
  }
}