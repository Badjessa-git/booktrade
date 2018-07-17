import 'dart:async';

import 'package:flutter/material.dart';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/ui/nav_ui/fin_book.dart';

class AddBook extends StatefulWidget {
  static Book curbook;
  dynamic cameras;
  AddBook(Future<Book> book, dynamic cameras) {
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
        title: const Text("Sell a book"),
      ),
      body: new Container(
        color: Colors.blue,
         child: new Form(
           child: new ListView(
             children: <Widget>[
               //isbn
               new Card(
                margin: const EdgeInsets.all(10.0),
                color: Colors.white,
                child: new TextFormField(
                  onSaved: (val) => _isbn = val,
                  decoration: const InputDecoration(
                    labelText: 'ISBN',
                    hintText: 'input isbn'
                  ),
                ),
               ),
               //title
               new Card(
                margin: const EdgeInsets.all(10.0),
                color: Colors.white,
                child: new TextFormField(
                 onSaved: (val) => _title = val,
                 decoration: const InputDecoration(
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
                 margin: const EdgeInsets.all(10.0),
                 color: Colors.white,
                 child:  new TextFormField(
                  onSaved: (val) => _edition = val,
                  decoration: const InputDecoration(
                   labelText: "Edition",
                   hintText: "input book edition"
                 ),
                ),
               ),
               //save
               new Card(
                 margin: const EdgeInsets.all(10.0),
                 child: new RaisedButton(
                  child: new Text("Next",
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push<MaterialPageRoute>(context, 
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
    Navigator.push<MaterialPageRoute>(context, 
                   new MaterialPageRoute(
                     builder: (context) => new FinBook(widget.cameras)
                  ));
    // final form = _formKey.currentState;

    // if (form.validate()) {
    //   form.save();
    //   _submitAll();
  
 }

  void _submitAll() {
    Navigator.push<MaterialPageRoute>(context, 
                   new MaterialPageRoute(
                     builder: (context) => new FinBook(widget.cameras)
                  )
      );
  }
}