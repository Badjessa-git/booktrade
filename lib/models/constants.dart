import 'package:booktrade/models/book.dart';

//
//  The device token value of the mobile phone
//
String deviceToken;

//
// Books being sold
//
List<Book> sellBooks = <Book>[];

//
// Books being sold by the user
//
List<Book> userSellBooks = <Book>[];

const String ADMOB_APPID_ANDROID = 'ca-app-pub-8785760726339346~9893390791';
const String ADDMOB_ADID_ANDROID = 'ca-app-pub-8785760726339346/5850714753';
const String ADMOB_APPID_IOS = 'ca-app-pub-8785760726339346~6884084076'; 
const String ADDMOB_ADID_IOS = 'ca-app-pub-8785760726339346/5248079521';
bool isIos = false;
Map<Book, String> bookMap = <Book, String>{};
Map<Book, String> wishMap = <Book, String>{};
