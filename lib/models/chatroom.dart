import 'package:booktrade/models/user.dart';
import 'package:meta/meta.dart';

class ChatRoom {
  final List<User> users;

  ChatRoom({
    @required this.users,
  });
}