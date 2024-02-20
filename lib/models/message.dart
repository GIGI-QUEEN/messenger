import 'package:cloud_firestore/cloud_firestore.dart';

enum Type { text, image, video }

class Message {
  //final String id;
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final String chatroomID;
  final Timestamp timestamp;
  final Type type;
  final bool read;

  Message({
    //required this.id,
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.chatroomID,
    required this.timestamp,
    required this.type,
    this.read = false,
  });

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      //'id': id,
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'chatroomID': chatroomID,
      'timestamp': timestamp,
      'type': type.toString(),
      'read': read,
    };
  }

  factory Message.fromFirebaseData(Map<String, dynamic> firebaseData) {
    return Message(
      senderID: firebaseData["senderID"],
      senderEmail: firebaseData["senderEmail"],
      receiverID: firebaseData["receiverID"],
      message: firebaseData["message"],
      chatroomID: firebaseData["chatroomID"],
      timestamp: firebaseData["timestamp"],
      type: firebaseData["type"],
    );
  }
}
