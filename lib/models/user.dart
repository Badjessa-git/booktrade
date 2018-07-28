import 'package:meta/meta.dart';

class User {
    final String displayName;
    final String email;
    final String school;

    User({
      @required this.displayName,
      @required this.email,
      @required this.school,
    });
}