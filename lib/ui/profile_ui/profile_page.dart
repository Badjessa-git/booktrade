import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/profile_ui/footer/profile_footer.dart';
import 'package:booktrade/ui/profile_ui/header/profile_header.dart';
import 'package:flutter/material.dart';

class ProfileDetails extends StatefulWidget {
  final User user;
  final TradeApi _api;
  const ProfileDetails(this.user, this._api);

  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new SingleChildScrollView(
        child: new Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new ProfileDetailHeader(widget.user),
              new ProfileDetailFooter(widget.user, widget._api),
            ],
          ),
        ),
      ),
    ); 
  }
}