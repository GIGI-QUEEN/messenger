import 'dart:developer';

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

  Message({
    //required this.id,
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.chatroomID,
    required this.timestamp,
    required this.type,
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
    };
  }
}
