import 'package:flutter/material.dart';
import 'package:booktrade/models/user.dart';

class ProfileDetailHeader extends StatefulWidget {

  final User user;
  const ProfileDetailHeader(this.user);

  @override
  _ProfileDetailHeaderState createState() => _ProfileDetailHeaderState();
}

class _ProfileDetailHeaderState extends State<ProfileDetailHeader> {

  final dynamic avatar = new Hero(
    tag: 'profile pic',
    
  );

  @override
  Widget build(BuildContext context) {
    return null;
  }
}