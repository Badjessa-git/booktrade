import 'package:booktrade/ui/book_ui/book_page.dart';
import 'package:booktrade/utils/routes.dart';
import 'package:booktrade/utils/tools.dart';
import 'package:flutter/material.dart';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/services/TradeApi.dart';

class BookListFound extends StatelessWidget {
  final TradeApi _api;
  final dynamic cameras;
  final Book _book;

  const BookListFound(this._api, this.cameras, this._book);

  @override
  Widget build(BuildContext context) {
    return _bookProto(context);
  }

    Widget _bookProto(BuildContext context) {
    final Book curbook = _book;
    return new Container(
      margin: const EdgeInsets.only(top: 5.0), 
      child: new Card(
        color: const Color(0xFFE4DFDA),
        child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new ListTile(
            leading: new Hero (
              tag: 'index',
              child: new SizedBox(
                height: 100.0,
                width: 60.0,
                child: new Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage( 
                      image: new NetworkImage(curbook.picUrl),
                      fit: BoxFit.contain,
                  ),
                ),
              ),  
            ),
          ),
          title: new Text(
            curbook.title,
            style: const TextStyle(fontWeight:  FontWeight.bold),
          ),
          subtitle: new Text(
            curbook.author + '\n' +
            Tools.convertToEdition(curbook.edition) + ' Edition\n' +
            curbook.sellerID,
            maxLines: 10,
            textAlign: TextAlign.left
          ),
          isThreeLine: true,
          dense: false,
          onTap: () => _navigateToNextPage(context, curbook, 'index'),
          trailing: curbook.sold == false
                  ? new Text('\$${curbook.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0
                    ),
                  )
                  : const Text(
                    'SOLD',
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.red,
                    ),
                  ),
          ),
        ],
      ),
      ),
    );
  }

  void _navigateToNextPage(BuildContext context, Book curbook, Object index) {
    Navigator.of(context).push<FadePageRoute<dynamic>>(
      new FadePageRoute<FadePageRoute<dynamic>>(
        builder: (BuildContext c) {
          return new BookDetails(curbook, index, _api, false, cameras: cameras);
        },
        settings: const RouteSettings(),
       ),
     );
  }

}