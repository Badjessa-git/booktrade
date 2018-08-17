import 'package:flutter/material.dart';
import 'package:booktrade/models/user.dart';

class ProfileDetailHeader extends StatefulWidget {

  final User user;
  const ProfileDetailHeader(this.user);

  @override
  _ProfileDetailHeaderState createState() => _ProfileDetailHeaderState();
}

class _ProfileDetailHeaderState extends State<ProfileDetailHeader> {


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textTheme = theme.accentColor;

    final dynamic avatar = new Hero(
      tag: 'profile pic',
      child: new CircleAvatar(
        backgroundImage:  new NetworkImage(widget.user.photoUrl),
        radius: 50.0,
      ),
    );


    return new Stack(
      children: <Widget>[
        new Align(
          alignment: FractionalOffset.bottomCenter,
          heightFactor: 1.4,
          child: new Column(
            children: <Widget>[
              avatar,
              new Text('${widget.user.displayName}',
                style: new TextStyle(
                  color: textTheme,
                  fontSize: 20.0,
                )
              )
            ],
          ),
        ),
        const Positioned(
          top: 24.0,
          left: 6.0,
          child: const BackButton(color: Colors.white),
        )
      ],
    );
  }
}