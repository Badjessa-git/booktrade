import 'package:meta/meta.dart';

class User implements Comparable<User>{
    final String displayName;
    final String email;
    final String school;
    final String photoUrl;

    User({
      @required this.displayName,
      @required this.email,
      @required this.school,
      @required this.photoUrl,
    });

  @override
  int compareTo(dynamic other) {
    if (other is User) {
      if (email == other.email) {
        return 0;
      }
    }
    return -1;
  }
}