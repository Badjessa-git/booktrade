import 'dart:io';

import 'package:flutter/material.dart';

class ImageDesign extends StatefulWidget {
  var _imagePath;

  ImageDesign(this._imagePath);

  @override
  _ImageDesignState createState() => new _ImageDesignState();
}

class _ImageDesignState extends State<ImageDesign> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      backgroundColor: Colors.blue,
       appBar: new AppBar(
         title: new Text("Finish"),
       ),
       body: new Container(
         margin: EdgeInsets.all(5.0),
           child: new Column(
              children: <Widget>[
                new Text("Cover Picture"),
                new Padding(
                  padding: EdgeInsets.all(5.0),
                  child: new SizedBox(
                      width: 100.0,
                      height: 100.0,
                      child: new Image.file(new File(widget._imagePath)),
                  ),
                ),
              ],
            ), 
        ),
      );
  }

}