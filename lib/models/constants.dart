import 'package:booktrade/models/book.dart';
import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:booktrade/ui/home.dart';
import 'package:booktrade/ui/nav_ui/navigation.dart';
import 'package:booktrade/ui/user_intro/intro.dart';
import 'package:booktrade/ui/wishlist_ui/wishlist_page.dart';
import 'package:camera/camera.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

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

///APPID for Admob on Android 
const String ADMOB_APPID_ANDROID = 'ca-app-pub-8785760726339346~9893390791';

///ADID for android
const String ADDMOB_ADID_ANDROID = 'ca-app-pub-8785760726339346/5850714753';

///APPID for IOS
const String ADMOB_APPID_IOS = 'ca-app-pub-8785760726339346~6884084076'; 

///ADID for ios
const String ADDMOB_ADID_IOS = 'ca-app-pub-8785760726339346/5248079521';

/// [true] if we are operating on an IOS phone
bool isIos = false;

/// [true] if ads are being displayed
bool isAdShown = true;

/// [true] if Disposed has been called on a [FirebaseAdmob] object
bool calledDisposed = false;

///[true] if the user accepts our terms
bool agreeToTerms = false;

///Contains a key, value pair of book and their documentID
Map<Book, String> bookMap = <Book, String>{};

///Same as bookMap
Map<Book, String> wishMap = <Book, String>{};

///Banner used for republishing if [calledDisposed] turns out to be true
BannerAd banner;

///List of cameras on the phone
List<CameraDescription> cCameras;

///The Api of the user, useful to construct routes
TradeApi cApi;

///Current User
User cUser;

///The different [routes] of the application
dynamic routes = <String, WidgetBuilder> {
        '/home' : (BuildContext context) => new Home(cCameras),
        '/Navigation' : (BuildContext context) => new Navigation(cApi, cCameras),
        '/Wishlist' : (BuildContext context) => new WishList(cUser, cApi),
        '/Intro' : (BuildContext context) => new Welcome(),
  };