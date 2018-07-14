import 'package:meta/meta.dart';

class Book {
  int id;
  final String isbn;
  final String title;
  final String author;
  final String edition;
  final String picUrl;
  final String sellerID;
  final String buyerID;

  Book ({
    @required this.id,
    @required this.isbn,
    @required this.title,
    @required this.author,
    @required this.edition,
    @required this.picUrl,
    @required this.sellerID,
    this.buyerID,
  });
}