import 'package:booktrade/models/book.dart';
import 'package:booktrade/utils/tools.dart';
import 'package:flutter/material.dart';

class BookInfo extends StatelessWidget{
  final Book bookInfo;

  const BookInfo(this.bookInfo);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: new Center(
        child:new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildCard(attribute: 'Author', attributeValue: bookInfo.title),
            _buildCard(attribute: 'ISBN', attributeValue: bookInfo.isbn.toString()),
            _buildCard(attribute: 'Author', attributeValue: bookInfo.author),
            _buildCard(attribute: 'Edition', attributeValue:Tools.convertToEdition(bookInfo.edition) + ' Edition'),
            _buildCard(attribute: 'Condition', attributeValue: bookInfo.condition),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({String attribute, String attributeValue}) {
    return new Card(
      margin: const EdgeInsets.only(top: 10.0),
      elevation: 5.0,
      child: new SizedBox(
        width: 400.0,
        child: new RichText(
          text: new TextSpan(
            style: const TextStyle(
              height: 1.5,
              fontSize: 20.0,
              color: Colors.black
            ),
            children: <TextSpan> [
              new TextSpan(text: '$attribute: ', style: const TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(text: '$attributeValue')
            ]
          ),
        ),
      ),
    );
  }

}