import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';
import 'dart:math' show Random;
import 'dart:typed_data' show ByteData;
import 'package:booktrade/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:booktrade/models/book.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:booktrade/models/constants.dart';

class TradeApi {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignin = new GoogleSignIn();
  static int id = 0;
  String displayName;
  FirebaseUser firebaseUser;
  Map<Book, String> bookMap =  <Book, String>{};
  TradeApi(this.firebaseUser);

  CollectionReference chatRoomsRef = Firestore.instance.collection('chatrooms');
  static Future<TradeApi> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignin.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return TradeApi(user);
  }

  static Future<TradeApi> ensureSignIn() async {
    final FirebaseUser currentUser = await _auth.currentUser();
    return currentUser == null ? null : TradeApi(currentUser);
  }

  Future<User> _checkDatabase() async {
    final FirebaseUser currentUser = await _auth.currentUser();
    final DocumentSnapshot check = await Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .get();
    return check.exists ? _fromUserSnapShot(check) : null;
  }

  Future<Null> addorUpdateUser({String schoolName, User otherUser}) async {
    final FirebaseUser currentUser = await _auth.currentUser();
    final User user = await _checkDatabase();
    if (user == null) {
      final List<String> deviceTokens = <String> [];
      deviceTokens.add(deviceToken);
      await Firestore.instance
          .collection('users')
          .document(currentUser.uid)
          .setData(<String, dynamic>{
        'displayName': currentUser.displayName,
        'email': currentUser.email,
        'school': schoolName,
        'userImg': currentUser.photoUrl,
        'deviceToken' : deviceTokens,
        'userUID': currentUser.uid,
        'notify' : true,
      });
    } else {
      if (user.displayName != currentUser.displayName ||
          user.email != currentUser.email ||
          user.photoUrl != currentUser.photoUrl ||
          !(user.deviceToken is List<String>) ||
          user.deviceToken.isEmpty ||
          !user.deviceToken.contains(deviceToken) ) {
        final DocumentReference userRef =
            Firestore.instance.collection('users').document(currentUser.uid);
        Firestore.instance.runTransaction((Transaction tx) async {
          final DocumentSnapshot userSnapsot = await tx.get(userRef);
          if (userSnapsot.exists) {
            List<String> deviceTokens = List<String>.from(userSnapsot.data['deviceToken']);
            deviceTokens == null ? 
            deviceTokens = <String> [deviceToken] 
            : !user.deviceToken.contains(deviceToken) ? deviceTokens.add(deviceToken) : null;
            await tx.update(userRef, <String, dynamic>{
              'displayName': currentUser.displayName,
              'email': currentUser.email,
              'school': user.school,
              'userImg': currentUser.photoUrl,
              'deviceToken' : deviceTokens,
              'userUID': currentUser.uid,
              'notify' : otherUser == null ? user.notify : otherUser.notify,
            });
          }
        });
      }
    }
  }

  static Future<Null> signOutWithGoogle() async {
    await _auth.signOut();
    await _googleSignin.signOut();
  }

  Future<List<String>> getAllChatrooms() async {
    final FirebaseUser curUser = await _auth.currentUser();
    final List<DocumentSnapshot> chatrooms = (await Firestore.instance
            .collection('users')
            .document(curUser.uid)
            .collection('engagedChatrooms')
            .getDocuments())
        .documents;

    final List<String> chatRooms = chatrooms
        .map((DocumentSnapshot doc) => _fromChatroomFirebase(doc))
        .toList();
    return chatRooms;
  }

  Future<User> fromChatRoomFirebase(String chatroomId) async {
    final FirebaseUser curUser = await _auth.currentUser();
    final DocumentSnapshot otherUserUID = await Firestore.instance
        .collection('chatrooms')
        .document(chatroomId)
        .get();
    final User otherUser = curUser.uid == otherUserUID.data['otherUserID']
        ? await getUser(otherUserUID.data['currentUserID'])
        : await getUser(otherUserUID.data['otherUserID']);
    return otherUser;
  }

  Future<String> getorCreateChatRomms(String otherUserId) async {
    final FirebaseUser curUser = await _auth.currentUser();
    String chatRoomID;
    await (Firestore.instance
        .collection('users')
        .document(curUser.uid)
        .collection('engagedChatrooms')
        .document(otherUserId)
        .get()).then<String>((DocumentSnapshot value) async {
      if (value.exists) {
        chatRoomID = _fromChatroomFirebase(value);
        return chatRoomID;
      }
      final String curUID = curUser.uid;

      final DocumentReference newChatRoom = chatRoomsRef.document();
      newChatRoom.setData(<String, dynamic>{
        'currentUserID': curUID,
        'otherUserID': otherUserId
      });
      await Firestore.instance
          .collection('users')
          .document(curUser.uid)
          .collection('engagedChatrooms')
          .document(otherUserId)
          .setData(<String, dynamic>{'chatroomID': newChatRoom.documentID});
      await Firestore.instance
          .collection('users')
          .document(otherUserId)
          .collection('engagedChatrooms')
          .document(curUID)
          .setData(<String, dynamic>{'chatroomID': newChatRoom.documentID});
      chatRoomID = newChatRoom.documentID;
    });
    return chatRoomID;
  }

  String _fromChatroomFirebase(DocumentSnapshot value) {
    final dynamic data = value.data;
    final String val = data['chatroomID'];
    return val;
  }

  static Future<Book> lookup(int isbn, TradeApi _api) async {
    final http.Response res = await http
        .get('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&num=10')
        .catchError((dynamic resp) {});
    if (res == null) {
      return null;
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      return null;
    }

    final dynamic jsonbook = json.decode(res.body)['items'];

    final dynamic book = jsonbook[0];

    if (jsonbook == null) {
      return null;
    }

    final Book resBook = new Book(
        title: book['volumeInfo']['title'],
        author: book['volumeInfo']['authors'][0],
        edition: book['volumeInfo']['edition'],
        isbn: isbn,
        picUrl: book['volumeInfo']['imageLinks']['thumbnail'],
        sellerID: _api.firebaseUser.displayName,
        sellerUID: _api.firebaseUser.uid,
        condition: '');

    return resBook;
  }

  Future<List<Book>> getAllBook() async {
    return (await Firestore.instance.collection('book_lehigh')
        .where('sold', isEqualTo: false)  
        .getDocuments())
        .documents
        .map((DocumentSnapshot doc) => _fromFireBaseSnapShot(doc, mapBook: bookMap))
        .toList();
  }
  
  Future<List<Book>> getUserBook() async {
    return (await Firestore.instance
            .collection('book_lehigh')
            .where('sellerUID', isEqualTo: firebaseUser.uid)
            .getDocuments())
        .documents
        .map((DocumentSnapshot doc) => _fromFireBaseSnapShot(doc))
        .toList();
  }

  Future<User> getUser(String userUID) async {
    final dynamic map =
        await Firestore.instance.collection('users').document(userUID).get();
    return _fromUserSnapShot(map);
  }

  Future<Null> sendMessage(
      {String messageText,
      String imageUrl,
      String chatroomID,
      int time,
      String receiverUID}) async {
    await Firestore.instance
        .collection('chatrooms')
        .document(chatroomID)
        .collection('messages')
        .document()
        .setData(<String, dynamic>{
          'message': messageText,
          'imageUrl': imageUrl,
          'name': firebaseUser.displayName,
          'userPic': firebaseUser.photoUrl,
          'email': firebaseUser.email,
          'time': time,
          'receiverUID' : receiverUID,
        });
  }

  Future<Null> uploadBook(Book book) async {
    await Firestore.instance
        .collection('book_lehigh')
        .document('${book.sellerUID}_${book.isbn}')
        .setData(<String, dynamic>{
          'isbn': book.isbn,
          'title': book.title,
          'author': book.author,
          'edition': book.edition,
          'picUrl': book.picUrl,
          'price': book.price,
          'seller': book.sellerID,
          'sellerUID': book.sellerUID,
          'condition': book.condition,
          'sold': book.sold
        });
  }

  StreamSubscription<DocumentSnapshot> watch(
      Book book, void onChange(Book book)) {
    return Firestore.instance
        .collection('book_lehigh')
        .document('${book.sellerUID}_${book.isbn}')
        .snapshots()
        .listen((DocumentSnapshot doc) => onChange( _fromFireBaseSnapShot(doc)));
  }

  Future<Null> updateBook(Book book, {bool sold}) async {
    final DocumentReference bookRef =
        Firestore.instance.collection('book_lehigh').document('${book.sellerUID}_${book.isbn}');
    Firestore.instance.runTransaction((Transaction tx) async {
      final DocumentSnapshot bookSnapshot = await tx.get(bookRef);
      if (bookSnapshot.exists) {
        await tx
            .update(bookRef, <String, dynamic>{
              'isbn': book.isbn,
              'title': book.title,
              'author': book.author,
              'edition': book.edition,
              'picUrl': book.picUrl,
              'price': book.price,
              'seller': book.sellerID,
              'sellerUID': book.sellerUID,
              'condition': book.condition,
              'sold': sold
            });
      }
    });
  }
  
  Future<Null> addToWishList(Book book) async {
  final String bookId = bookMap[book];
  await Firestore.instance.collection('users')
                                   .document(firebaseUser.uid)
                                   .collection('wishlist')
                                   .document(bookId)
                                   .setData(<String, dynamic> {
                                     'bookId' : bookId
                                   });
  
  List<String> userList = <String>[];
  await Firestore.instance.collection('wishlist')
                                    .document(bookId)
                                    .get()
                                    .then((DocumentSnapshot doc) {
                                      if (doc.exists) {
                                        userList = List<String>.from(doc.data['users']);
                                      }
                                    });
                    
  
  userList == null || userList.isEmpty
  ? userList = <String> [firebaseUser.uid] 
  : !userList.contains(firebaseUser.uid)
  ? userList.add(firebaseUser.uid)
  : null; 

  await Firestore.instance.collection('wishlist')
                            .document(bookId)
                            .setData(<String, dynamic> {
                              'users' : userList
                            });
  }
  
  Future<Null> removeFromWishList(Book book) async {
    final String bookId = bookMap[book];
    await Firestore.instance.collection('users')
                            .document(firebaseUser.uid)
                            .collection('wishlist')
                            .document(bookId)
                            .delete().then((_) => bookMap.remove(book))
                                     .catchError(() => print('Error deleting book'));

   final List<String> users = List<String>.from((await Firestore.instance.collection('wishlist')
                            .document(bookId)
                            .get())
                            .data['users']);
    while (users.contains(firebaseUser.uid)) {
      users.remove(firebaseUser.uid);
    }

  await Firestore.instance.collection('wishlist')
                            .document(bookId)
                            .setData(<String, dynamic> {
                              'users' : users
                            }).catchError(() => print('Error with deletion in removeFormWihslist'));              
  }
  
  Future<List<Book>> getWishList() async {
    final List<String> _bookID = (await Firestore.instance.collection('users')
                                    .document(firebaseUser.uid)
                                    .collection('wishlist')
                                    .getDocuments())
                                    .documents
                                    .map<String>((DocumentSnapshot doc) => doc.data['bookId'])
                                    .toList();

    final List<Book> finalBook = <Book>[];
    for(String doc in _bookID) {
      finalBook.add(await findBook(doc));
    }
    return finalBook;
  }


  Future<Book> findBook(String doc) async {
    final String bookID = doc;
    return await Firestore.instance.collection('book_lehigh')
                                   .document(bookID)
                                   .get()
                                   .then((DocumentSnapshot doc) => _fromFireBaseSnapShot(doc));
  }
  Future<Null> deleteBook(Book book) async {
    await Firestore.instance
        .collection('book_lehigh')
        .document('${book.sellerUID}_${book.isbn}')
        .delete();
  }

  Future<String> uploadFile({String filePath, int isbn}) async {
    final ByteData bytes = await rootBundle.load(filePath);
    final Directory tempDir = Directory.systemTemp;
    final String fileName = '${Random().nextInt(1000)}.jpg';
    final File file = File('${tempDir.path}/$fileName');
    file.writeAsBytes(bytes.buffer.asInt8List(), mode: FileMode.write);
    final dynamic finalVal = isbn == null ? fileName : isbn;
    final StorageReference ref =
        FirebaseStorage.instance.ref().child(finalVal.toString());
    final StorageUploadTask task = ref.putFile(file);
    final Uri downloadUrl = (await task.future).downloadUrl;
    final String _path = downloadUrl.toString();
    return _path;
  }

  Book _fromFireBaseSnapShot(DocumentSnapshot doc, {Map<Book, String>mapBook}) {
    final dynamic data = doc.data;
    if (mapBook == null) {
      return new Book(
        isbn: data['isbn'],
        title: data['title'],
        author: data['author'],
        edition: data['edition'],
        picUrl: data['picUrl'],
        price: data['price'],
        sellerID: data['seller'],
        sellerUID: data['sellerUID'],
        condition: data['condition'],
        sold: data['sold']);
    } else {
      final Book book = new Book(
        isbn: data['isbn'],
        title: data['title'],
        author: data['author'],
        edition: data['edition'],
        picUrl: data['picUrl'],
        price: data['price'],
        sellerID: data['seller'],
        sellerUID: data['sellerUID'],
        condition: data['condition'],
        sold: data['sold']);
        mapBook.putIfAbsent(book, () => doc.documentID);
        return book;
    }
  }
    
  

  User _fromUserSnapShot(DocumentSnapshot doc) {
    final dynamic data = doc.data;
    return new User(
      displayName: data['displayName'],
      email: data['email'],
      school: data['school'],
      photoUrl: data['userImg'],
      deviceToken: List<String>.from(data['deviceToken']), 
      uid: data['userUID'],
      notify: data['notify'] == null ? true : data['notify'],
      
    );  
  }
}
