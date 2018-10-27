import 'package:meta/meta.dart';

class User implements Comparable<User>{
    User({
      @required this.displayName,
      @required this.email,
      @required this.school,
      @required this.photoUrl,
      @required this.uid, 
      @required this.deviceToken,
      @required this.notify,
    });

    final String displayName;
    final String email;
    final String school;
    final String photoUrl;
    final String uid;
    final List<String> deviceToken;
    bool notify;

  void addToken(String token) {
    deviceToken.add(token);
  }  

  @override
  int compareTo(dynamic other) {
    if (other is User) {
      if (email == other.email) {
         if (school == other.school) {
           if (photoUrl == other.photoUrl) {
             if (uid == other.uid) {
               return 0;
             }
           }
         }
      }
    }
    return -1;
  }
}