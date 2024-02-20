import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  //final String image;
  final String username;
  final Timestamp timestamp;

  User({
    required this.uid,
    required this.email,
    // required this.image,
    required this.username,
    required this.timestamp,
  });
/* 
  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      //'image': image,
      'username': username,
      'timestamp': timestamp,
    };
  } */
}
