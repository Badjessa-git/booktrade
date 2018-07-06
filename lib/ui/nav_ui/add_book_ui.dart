import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lutexttrade/models/book.dart';
import 'package:lutexttrade/ui/nav_ui/fin_book.dart';

class AddBook extends StatefulWidget {
  static Book curbook;
  var cameras;
  AddBook(Future<Book> book, cameras) {
    if (book == null)
      curbook = book as Book;
    this.cameras = cameras;
  }

  @override
  _AddBook createState() => new _AddBook();
  
  }
  
class _AddBook extends State<AddBook> {

  @override
  void initState(){
    super.initState();
  }

  String _isbn;
  String _title;
  String _author;
  String _edition;

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Sell a book"),
      ),
      body: new Container(
        color: Colors.blue,
         child: new Form(
           child: new ListView(
             children: <Widget>[
               //isbn
               new Card(
                margin: EdgeInsets.all(10.0),
                color: Colors.white,
                child: new TextFormField(
                  onSaved: (val) => _isbn = val,
                  decoration: new InputDecoration(
                    labelText: "ISBN",
                    hintText: "input isbn"
                  ),
                ),
               ),
               //title
               new Card(
                margin: EdgeInsets.all(10.0),
                color: Colors.white,
                child: new TextFormField(
                 onSaved: (val) => _title = val,
                 decoration: new InputDecoration(
                   labelText: "Title",
                   hintText: "input title"
                 ),
                ),
               ),
               //author
               new Card(
                 margin: EdgeInsets.all(10.0),
                 color: Colors.white,
                 child: new TextFormField(
                    onSaved: (val) => _author = val,
                    decoration: new InputDecoration(
                      labelText: "Author",
                      hintText: "input book Author(s)"
                  ), 
                ),
               ),
               //edtion
               new Card(
                 margin: EdgeInsets.all(10.0),
                 color: Colors.white,
                 child:  new TextFormField(
                  onSaved: (val) => _edition = val,
                  decoration: new InputDecoration(
                   labelText: "Edition",
                   hintText: "input book edition"
                 ),
                ),
               ),
               //save
               new Card(
                 margin: EdgeInsets.all(10.0),
                 child: new RaisedButton(
                  child: new Text("Next",
                    style: new TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: () {Navigator.push(context, 
                   new MaterialPageRoute(
                     builder: (context) => new FinBook(widget.cameras)
                  ));
                  },
                ),
               ),
             ]
           ),
         ),
      ),
    );
  }

  void _submit() {
    Navigator.push(context, 
                   new MaterialPageRoute(
                     builder: (context) => new FinBook(widget.cameras)
                  ));
    // final form = _formKey.currentState;

    // if (form.validate()) {
    //   form.save();
    //   _submitAll();
  
 }

  void _submitAll() {
    Navigator.push(context, 
                   new MaterialPageRoute(
                     builder: (context) => new FinBook(widget.cameras)
                  )
      );
  }
}