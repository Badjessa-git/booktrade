import 'package:meta/meta.dart';

class Book {
  final String price;
  final String isbn;
  final String title;
  final String author;
  final String edition;
  String picUrl;
  final String sellerID;
  final String buyerID;

  Book ({
    @required this.isbn,
    @required this.title,
    @required this.author,
    @required this.edition,
    @required this.picUrl,
    @required this.sellerID,
    this.buyerID,
    this.price, 
  });
}