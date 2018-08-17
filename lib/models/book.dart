import 'package:meta/meta.dart';

class Book implements Comparable<Book> {
  double price;
  final int isbn;
  final String title;
  final String author;
  final int edition;
  String condition;
  final String sellerUID;
  String picUrl;
  String sellerID;
  bool sold;

  Book ({
    @required this.isbn,
    @required this.title,
    @required this.author,
    @required this.edition,
    @required this.picUrl,
    @required this.sellerID,
    @required this.condition,
    @required this.sellerUID,
    this.sold = false,
    this.price, 
  });

  @override
  int compareTo(dynamic other) {
    if (other is Book) {
      if (other.isbn == isbn) {
        if (other.sellerUID == sellerUID) {
          return 0;
        }
      }
    }
    return -1;
  }
}