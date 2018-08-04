import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';
import 'dart:math' show Random;
import 'dart:typed_data' show ByteData;
import 'package:booktrade/models/chatroom.dart';
import 'package:booktrade/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:booktrade/models/book.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class TradeApi {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignin = new GoogleSignIn();
  static int id = 0;
  String displayName;
  FirebaseUser firebaseUser;
  TradeApi(this.firebaseUser);
   
  CollectionReference chatRoomsRef = Firestore.instance.collection('chatrooms');
  DocumentReference curUserRef;
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

  Future<bool> _checkDatabase() async {
    final FirebaseUser currentUser = await _auth.currentUser();    
    final DocumentSnapshot check =  await Firestore.instance.collection('users').document(currentUser.uid).get();
    return check.exists;
  }

  Future<Null> pushToUserCollection(String schoolName) async {
    final FirebaseUser currentUser = await _auth.currentUser();
    if (await _checkDatabase() == false) {
      await Firestore.instance.collection('users').document(currentUser.uid).setData(<String, dynamic>{
        'displayName' : currentUser.displayName,
        'email' : currentUser.email,
        'school' : schoolName,
        'userImg' : currentUser.photoUrl,
    });
      curUserRef = Firestore.instance.collection('users').document(currentUser.uid);
    }    
  }
  static Future<Null> siginOutWithGoogle() async {
    await _auth.signOut();
    await _googleSignin.signOut();
  }

  Future<List<String>> getAllChatrooms() async {
    final FirebaseUser curUser = await _auth.currentUser();
    final List<DocumentSnapshot> chatrooms = (await Firestore.instance.collection('users')
                            .document(curUser.uid)
                            .collection('engagedChatrooms')
                            .getDocuments())
                            .documents;

    final List<String> chatRooms = chatrooms.map((DocumentSnapshot doc) => _fromChatroomFirebase(doc))
                                            .toList();
    return chatRooms;
  }



  Future<User> fromChatRoomFirebase(String chatroomId) async{
    final String otherUserUID = (await Firestore.instance.collection('chatrooms')
                                                        .document(chatroomId)
                                                        .get())
                                                        .data['otherUserID'];
    final User otherUser = await getUser(otherUserUID);
    return otherUser;
  } 

  Future<String> getorCreateChatRomms(String otherUserId ) async {
    final FirebaseUser curUser = await _auth.currentUser();
    String chatRoomID;
    await (Firestore.instance.collection('users')
              .document(curUser.uid)
              .collection('engagedChatrooms')
              .document(otherUserId)
              .get())
              .then<String>((DocumentSnapshot value) async {
                if (value.exists) {
                 chatRoomID = _fromChatroomFirebase(value);
                 return chatRoomID;
                }
                final String curUID = curUser.uid;

                final DocumentReference newChatRoom = chatRoomsRef.document(otherUserId);
                newChatRoom.setData(<String, dynamic> {
                  'currentUserID' : curUID,
                  'otherUserID' : otherUserId
                });
                await Firestore.instance.collection('users')
                                  .document(curUser.uid)
                                  .collection('engagedChatrooms')
                                  .document(otherUserId)
                                  .setData(<String, dynamic>{
                                    'chatroomID' : newChatRoom.documentID
                                  });
                await Firestore.instance.collection('users')
                                  .document(otherUserId)
                                  .collection('engagedChatrooms')
                                  .document(curUID)
                                  .setData(<String, dynamic>{
                                    'chatroomID' : newChatRoom.documentID
                                  });
                chatRoomID = newChatRoom.documentID;
              });
        return chatRoomID;
  }
  
  String _fromChatroomFirebase(DocumentSnapshot value) {
    final dynamic data = value.data;
    final String val =  data['chatroomID'];
    return val;
  }
  
  static Future<Book> lookup(int isbn, TradeApi _api) async {
      final http.Response res = await http.get('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&num=10')
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
                      condition: ''
                      );

      return resBook;
  }

  Future<List<Book>> getAllBook() async {
    return (await Firestore.instance.collection('book_lehigh').getDocuments())
          .documents
          .map((DocumentSnapshot doc) => _fromFireBaseSnapShot(doc))
          .toList();
  }

  Future<List<Book>> getUserBook() async{
    return (await Firestore.instance.collection('book_lehigh')
            .where('sellerUID', isEqualTo: firebaseUser.uid)
            .getDocuments())
            .documents
            .map((DocumentSnapshot doc) => _fromFireBaseSnapShot(doc))
            .toList();
  }

  Future<User> getUser(String userUID) async{
    final dynamic map= await Firestore.instance.collection('users')
                           .document(userUID)
                           .get();
    return _fromUserSnapShot(map);
  }

  Future<Null> sendMessage({String messageText, String imageUrl, String chatroomID, int time})  async {
    await Firestore.instance.collection('chatrooms')
                            .document(chatroomID)
                            .collection('messages')
                            .document()
                            .setData(<String, dynamic>{
                              'message': messageText,
                              'imageUrl': imageUrl,
                              'name': firebaseUser.displayName,
                              'userPic': firebaseUser.photoUrl,
                              'time': time
                            });
                                                   
  }

  Future<Null> uploadBook(Book book) async {
    await Firestore.instance.collection('book_lehigh')
                            .document(book.sellerUID)
                            .setData(<String, dynamic>{
                              'isbn' : book.isbn,
                              'title': book.title,
                              'author': book.author,
                              'edition': book.edition,
                              'picUrl':  book.picUrl,
                              'price': book.price,
                              'seller': book.sellerID,
                              'sellerUID': book.sellerUID,
                              'condition': book.condition
                            });
  } 
  
  StreamSubscription<DocumentSnapshot> watch(Book book, void onChange(Book book)) {
    return Firestore.instance.collection('book_lehigh')
           .document(book.sellerUID)
           .snapshots()
           .listen((DocumentSnapshot doc) => onChange(_fromFireBaseSnapShot(doc)));
  }

  Future<String> uploadFile({String filePath, int isbn}) async{
    final ByteData bytes = await rootBundle.load(filePath);
    final Directory tempDir = Directory.systemTemp;
    final String fileName = '${Random().nextInt(1000)}.jpg';
    final File file = File('${tempDir.path}/$fileName');
    file.writeAsBytes(bytes.buffer.asInt8List(), mode: FileMode.write);
    final dynamic finalVal = isbn == null ? fileName : isbn;
    final StorageReference ref = FirebaseStorage.instance.ref().child(finalVal.toString());
    final StorageUploadTask task = ref.putFile(file);
    final Uri downloadUrl = (await task.future).downloadUrl;
    final String _path = downloadUrl.toString();
    return _path;
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
      sellerUID: data['sellerUID'],
      condition: ''
    );
  }

  User _fromUserSnapShot(DocumentSnapshot doc) {
    final dynamic data = doc.data;
    return new User(
      displayName: data['displayName'],
      email: data['email'],
      school: data['school'],
      photoUrl: data['userImg'],
    );
  }
}

