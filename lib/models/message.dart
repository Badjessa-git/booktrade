class Message {
   Message(this.receiverUID, {this.imageUrl, this.name, this.message, this.time, this.userPic});

  final String name;
  final String message;
  final String time;
  final String userPic;
  final String imageUrl;
  final String receiverUID;

}
