import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

class Welcome extends StatelessWidget {
  static const Color pageColor = const Color(0xFF194843);
  static const TextStyle style = const TextStyle(fontSize: 40);
  final List<PageViewModel> pages = <PageViewModel> [
    new PageViewModel(
      pageColor: pageColor,
      iconImageAssetPath: null,
      title: const Text('Welcome to BookTrade'),
      body: const Text(
        'A new way to sell and buy books with other studnets on your campus'
      ),
      mainImage: null
    ),
    new PageViewModel(
      pageColor: pageColor,
      iconImageAssetPath: 'assets/img/buying.png',
      body: const Text(
        'Take a look at all the list posted here'
      ),
      title: const Text('Listed Books', style: style,),
      textStyle: const TextStyle(color: Colors.white),
      mainImage: Image.asset(
        'assets/img/buying.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      )
    ),
    new PageViewModel(
      pageColor: pageColor,
      iconImageAssetPath: 'assets/img/selling.png',
      body: const Text(
        'The books you sell will be posted here, Press on + to add new books'
      ),
      title: const Text('List your Books', style: style,),
      textStyle: const TextStyle(color: Colors.white),
      mainImage: Image.asset(
        'assets/img/selling.png',
        width: 285.0,
        height: 285.0,
        alignment: Alignment.center,
      )
    ),
    new PageViewModel(
      pageColor: pageColor,
      iconImageAssetPath: 'assets/img/addBook.png',
      body: const Text(
        'You can autofill the book by looking up the ibsn number'
      ),
      title: const Text('Add new books', style: style,),
      mainImage: Image.asset(
        'assets/img/addBook.png',
        width: 285.0,
        height: 285.0,
        alignment: Alignment.center,
      )
    ),
    new PageViewModel(
      pageColor: pageColor,
      iconImageAssetPath: 'assets/img/addBook2.png',
      title: const Text('Add new Books', style: style,),
      body: const Text(
        'Or you can fill up the details about the book yourself'
      ),
      mainImage: Image.asset(
        'assets/img/addBook2.png',
        width: 285.0,
        height: 285.0,
        alignment: Alignment.center,
      )
    ),
    new PageViewModel(
      pageColor: pageColor,
      iconImageAssetPath: 'assets/img/search.png',
      title: const Text('Search by Title or ISBN', style: style,),
      body: const Text(
        'Look up books that you need'
      ),
      mainImage: Image.asset(
        'assets/img/search.png',
        width: 285.0,
        height: 285.0,
        alignment: Alignment.center,
      )
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return new IntroViewsFlutter(
      pages,
      onTapDoneButton: () {
        Navigator.pushNamed(context, '/Navigation');         
        },
      showSkipButton: true,
      );
  }

}