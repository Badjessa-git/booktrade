import 'dart:math';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/book_ui/fin_book.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/models/book.dart';

class AddBook extends StatefulWidget {
  Book curbook;
  final dynamic cameras;
  final TradeApi _api;
  AddBook(this.curbook,  this.cameras, this._api);

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
  String _price;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(),
      body: new Container(
        color: const Color(0xFFE4DFDA),
         child: new Form(
           key: _formKey,
           child: new ListView(
             children: <Widget>[
               const SizedBox(
                  width: 40.0,
                  height: 60.0,
                  child: const Text('Sell Book',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
               ),
               //isbn
               new Card(
                margin: const EdgeInsets.all(10.0),
                color: Colors.white,
                child: new TextFormField(
                  // validator: (String value) {
                  //   if (value.isEmpty) {
                  //     return 'Please Enter the ISBN number';
                  //   } else if (num.parse(value) == null) {
                  //     return 'Please only input numbers';
                  //   }
                  // },
                  onSaved: (String val) => _isbn = val,
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
                  // validator: (String value) {
                  //   if (value.isEmpty) {
                  //     return 'Please enter the title of the TextBook';
                  //   }
                  // },
                 onSaved: (String val) => _title = val,
                 decoration: const InputDecoration(
                   labelText: 'Title',
                   hintText: 'input title',
                 ),
                ),
               ),
               //author
               new Card(
                 margin: const EdgeInsets.all(10.0),
                 color: Colors.white,
                 child: new TextFormField(
                  //  validator: (String value) {
                  //    if (value.isEmpty) {
                  //      return 'Please Enter the author of the book';
                  //    }
                  //  },
                    onSaved: (String val) => _author = val,
                    decoration: const InputDecoration(
                      labelText: 'Author',
                      hintText: 'input book Author(s)'
                  ), 
                ),
               ),
               //edtion
               new Card(
                 margin: const EdgeInsets.all(10.0),
                 color: Colors.white,
                 child:  new TextFormField(
                  // validator: (String value) {
                  //   if (value.isEmpty) {
                  //     return 'Please enter the book Edition';
                  //   } else if (int.parse(value) == null) {
                  //     return 'Enter a number for the edition';
                  //   }
                  // },
                  onSaved: (String val) => _edition = val,
                  decoration: const InputDecoration(
                   labelText: 'Edition',
                   hintText: 'Input book edition'
                 ),
                ),
               ),
                  //price
                  new Card(
                    margin: const EdgeInsets.all(10.0),
                    color: Colors.white,
                    child:  new TextFormField(
                      // validator: (String value) {
                      //   if (value.isEmpty) {
                      //     return 'Enter the amount offered for the book';
                      //   } else if (double.parse(value) == null) {
                      //     return 'The amount has to be a number';
                      //   } else {
                      //     _price = value;
                      //   }
                      // },
                      onSaved: (String val) => _price = val,
                      decoration: const InputDecoration(
                      labelText: 'Price',
                      hintText: 'input value of book'
                      ),
                    ),
                  ),
               //save
               new Card(
                 margin: const EdgeInsets.all(10.0),
                 child: new MaterialButton(
                  height: 50.0,
                  color: const Color(0xFF48A9A6),
                  child: const Text('Next',
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: () {
                      _formKey.currentState.validate()
                        ? _submit()
                        : null;
                        }
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _submit() {
    widget.curbook ??= new Book(
        id: new Random().nextInt(10000001), 
        title: _title, 
        author: _author, 
        edition: _edition, 
        isbn: _isbn, 
        picUrl: null, 
        price: _price,
        sellerID: widget._api.firebaseUser.displayName,
      );
    Navigator.push<MaterialPageRoute<PageRoute<dynamic>>>(context, 
                   new MaterialPageRoute<MaterialPageRoute<PageRoute<dynamic>>>(
                     builder: (BuildContext context) => new FinBook(widget.cameras, widget.curbook)
                  ),
                );
  }

}