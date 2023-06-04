import 'package:firebase_database/firebase_database.dart';

class Message {
  // String ? messageId;
  String ? msg;
  String? senderId;
  // String? receiverId;
  // String? ImageUrl;
  String? type;
  String?timeStamp;

  // Message({this.messageId,this.msg,this.senderId,this.receiverId,this.type,required this.timeStamp});
  Message({this.msg,this.senderId,this.timeStamp,this.type});
  // Message.fromMap(Map<String, dynamic>map)
  // {
  //   msg=map['message'];
  //   senderId=map['sender'];
  //   timeStamp=DateTime.fromMillisecondsSinceEpoch(map['timestamp']);
  // }
  // Map<String,dynamic> toMap(){
  //   return{
  //     'message':msg,
  //     'sender':senderId,
  //     'timestamp':timeStamp?.millisecondsSinceEpoch,
  //   };


}