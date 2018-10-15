import 'dart:async';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/book_ui/fin_book.dart';
import 'package:booktrade/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/models/book.dart';

class AddBook extends StatefulWidget {
  final Book curbook;
  final dynamic cameras;
  final TradeApi _api;
  const AddBook(this.curbook,  this.cameras, this._api);

  @override
  _AddBook createState() => new _AddBook();
  
  }
  
class _AddBook extends State<AddBook> {
  final List<String> conditions = <String>['Excellent', 'Very Good', 'Good', 'Poor'];
  Book curbook;
  int _isbn;
  String _title;
  String _author;
  int _edition;
  double _price;
  String _condition;


  TextEditingController isbn = new TextEditingController();
  TextEditingController title = new TextEditingController();
  TextEditingController author = new TextEditingController();
  TextEditingController edition = new TextEditingController();
  TextEditingController price = new TextEditingController();


  @override
  void initState() {
    super.initState();
    _condition = conditions.first;
    if (widget.curbook != null) {
      setState(() {
        _isbn = widget.curbook.isbn;
        _title = widget.curbook.title;
        _author = widget.curbook.author;
        _edition = widget.curbook.edition;
        widget.curbook.price != null ? _price = widget.curbook.price : () {};     
        curbook = widget.curbook;   
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        leading: new WillPopScope(
          onWillPop: () {
            if (!isAdShown && calledDisposed) {
              banner = TradeApi.createBannerAd();
              banner..load()..show();
              isAdShown = true;
              calledDisposed = false;
            }
            return Future<bool>.value(true);
          },
          child: const BackButton()        
        ),
      ),
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
                  initialValue: _isbn != null
                              ? '$_isbn'
                              : '',
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please Enter the ISBN number';
                    } else if (int.parse(value) == null) {
                      return 'Please only Enter numbers';
                    } else {
                      _isbn = int.parse(value);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'ISBN',
                    hintText: 'Enter isbn'
                  ),
                ),
               ),
               //title
               new Card(
                margin: const EdgeInsets.all(10.0),
                color: Colors.white,
                child: new TextFormField(
                  initialValue: _title != null && _title.isNotEmpty
                              ? _title
                              : '',
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter the title of the TextBook';
                    } else {
                      _title = value;
                    }
                  },
                 decoration: const InputDecoration(
                   labelText: 'Title',
                   hintText: 'Enter title',
                 ),
                ),
               ),
               //author
               new Card(
                 margin: const EdgeInsets.all(10.0),
                 color: Colors.white,
                 child: new TextFormField(
                   initialValue: _author != null && _author.isNotEmpty
                               ? _author
                               : '',    
                   validator: (String value) {
                     if (value.isEmpty) {
                       return 'Please Enter the author of the book';
                     } else {
                       _author = value;
                     }
                   },
                    decoration: const InputDecoration(
                      labelText: 'Author',
                      hintText: 'Enter book Author(s)'
                  ), 
                ),
               ),
               //edtion
               new Card(
                 margin: const EdgeInsets.all(10.0),
                 color: Colors.white,
                 child:  new TextFormField(
                  initialValue: _edition != null
                              ? '$_edition'
                              : '', 
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter the book Edition';
                    } else if (int.parse(value) == null) {
                      //int edition = Tools.checkVal(value);
                      return 'Make sure to enter whole numbers';
                    } else {
                      _edition = int.parse(value);
                    }
                  },
                  decoration: const InputDecoration(
                   labelText: 'Edition',
                   hintText: 'Enter book edition (just the number)'
                 ),
                ),
               ),

               //Condition
               new Card(
                 margin: const EdgeInsets.all(10.0),
                 child: new ListTile(
                   contentPadding: const EdgeInsets.all(0.0),
                 leading: new Text('Condition',
                    style: new TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700]),
                    ),
                trailing: new Card(
                color: Colors.white,
                child: new DropdownButton<String>(
                  onChanged: (String value) {
                    setState(() {
                       _condition = value;                        
                    });
                  }, 
                  value: _condition,
                  items: conditions.map((String value) {
                      return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                      );
                  }).toList(),
                ),
              ),
             ),
            ),

              //price
              new Card(
                margin: const EdgeInsets.all(10.0),
                  color: Colors.white,
                  child:  new TextFormField(
                    initialValue: _price != null
                                  ? '$_price'
                                  : '', 
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Enter the amount offered for the book';
                      } else if (double.parse(value) == null) {
                        return 'The amount has to be a number';
                      } else {
                        _price = double.parse(value);
                      }
                    },
                    decoration: const InputDecoration(
                    labelText: 'Price',
                    hintText: 'Enter value of book',
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
                const Divider(height: 100.0,)
                  ],
                ),
              ),
            ),
    );
  }

  void _submit() {
        curbook = new Book(
        title: _title, 
        author: _author, 
        edition: _edition, 
        isbn: _isbn, 
        picUrl: null,
        condition: _condition, 
        price: _price,
        sellerID: widget._api.firebaseUser.displayName,
        sellerUID: widget._api.firebaseUser.uid,
        );
  
    Navigator.push<MaterialPageRoute<PageRoute<dynamic>>>(context, 
                   new MaterialPageRoute<MaterialPageRoute<PageRoute<dynamic>>>(
                     builder: (BuildContext context) => new FinBook(widget.cameras, curbook, widget._api)
                  ),
                );
  }

}