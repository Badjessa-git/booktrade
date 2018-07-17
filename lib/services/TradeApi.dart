import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:booktrade/models/book.dart';
import 'package:http/http.dart' as http;

class TradeApi {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignin = new GoogleSignIn();
  static int id = 0;
  FirebaseUser firebaseUser;

  TradeApi(FirebaseUser user){
    firebaseUser = user;
  }


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

  static List<Book> booksFromFile(String file) {
    List<Book> books = [];
    Book book;
    json.decode(file)['books'].forEach((dynamic book) => books.add(_fromMap(book)));
    return books;
  }
    
  static Future<Book> lookup(String isbn, TradeApi _api) async {
      http.Response res = await http.get("https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn")
                          .catchError((dynamic resp) {});
      if (res == null) {
        return null;
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        return null;
      }

      dynamic jsonbook = json.decode(res.body);

      dynamic book = jsonbook[0];

      Book resBook = new Book(
                      title: book["volumeInfo"]["title"],
                      author: book["volumeInfo"]["authors"], 
                      edition: book["volumeInfo"]["edition"], 
                      id: book["volumeInfo"]["id"], 
                      isbn: isbn, 
                      picUrl: book["volumeInfo"]["thumbnail"], 
                      sellerID: _api.firebaseUser.displayName,
                      );

      return resBook;
  }

  static Book _fromMap(Map<String, dynamic> map) {
    
    return new Book (
      id : id++,
      isbn : map['isbn'],
      title: map['title'],
      author: map['author'],
      edition: map['edition'],
      picUrl:  map['picUrl'],
      sellerID: "Romeo Bahoumda",
    );
  }
}

