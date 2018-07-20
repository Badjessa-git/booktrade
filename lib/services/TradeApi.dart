import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:booktrade/models/book.dart';
import 'package:http/http.dart' as http;

class TradeApi {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignin = new GoogleSignIn();
  static int id = 0;
  FirebaseUser firebaseUser;

  TradeApi(this.firebaseUser);


  static Future<TradeApi> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignin.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    final FirebaseUser currentUser = await _auth.currentUser();
    
    assert(user.uid == currentUser.uid);

    return TradeApi(user);
  }

  static Future<Null> siginOutWithGoogle() async {
    await _auth.signOut();
    await _googleSignin.signOut();
  }

  static List<Book> booksFromFile(String file) {
    final List<Book> books = <Book>[];
    json.decode(file)['books'].forEach((dynamic book) => books.add(_fromMap(book)));
    return books;
  }
    
  static Future<Book> lookup(String isbn, TradeApi _api) async {
      final http.Response res = await http.get('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn')
                          .catchError((dynamic resp) {});
      if (res == null) {
        return null;
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        return null;
      }

      final dynamic jsonbook = json.decode(res.body);

      final dynamic book = jsonbook[0];

      final Book resBook = new Book(
                      title: book['volumeInfo']['title'],
                      author: book['volumeInfo']['authors'], 
                      edition: book['volumeInfo']['edition'], 
                      isbn: isbn, 
                      picUrl: book['volumeInfo']['thumbnail'], 
                      sellerID: _api.firebaseUser.displayName,
                      );

      return resBook;
  }

  Future<List<Book>> getAllBook() async {
    return (await Firestore.instance.collection('book_lehigh').getDocuments())
          .documents
          .map((DocumentSnapshot doc) => _fromFireBaseSnapShot(doc))
          .toList();
  }

  StreamSubscription<DocumentSnapshot> watch(Book book, void onChange(Book book)) {
    return Firestore.instance.collection('book_lehigh')
           .document(book.isbn)
           .snapshots()
           .listen((DocumentSnapshot doc) => onChange(_fromFireBaseSnapShot(doc)));
  }

  Book _fromFireBaseSnapShot(DocumentSnapshot doc) {
    final dynamic data = doc.data;
    return new Book (
      isbn : data['isbn'],
      title: data['title'],
      author: data['author'],
      edition: data['edition'],
      picUrl:  data['picUrl'],
      price: data['price'],
      sellerID: data['seller'],
    );
  }

  static Book _fromMap(Map<String, dynamic> map) {
    
    return new Book (
      isbn : map['isbn'],
      title: map['title'],
      author: map['author'],
      edition: map['edition'],
      picUrl:  map['picUrl'],
      sellerID: 'Romeo Bahoumda',
    );
  }
}

