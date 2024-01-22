import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secure_messenger/models/message.dart';

class ChatService {
  // get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();

        // return user
        return user;
      }).toList();
    });
  }

  // get contact stream
  Stream<List<Map<String, dynamic>>> getContactsStream(String currentUserID) {
    return _firestore
        .collection('users')
        .doc(currentUserID)
        .collection('contacts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual contact
        final contact = doc.data();

        // return contact
        return contact;
      }).toList();
    });
  }

  // add user to contacts
  Future<void> addUserToContacts(String otherUserEmail) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;

    // retrieve the other user's document based on their email
    QuerySnapshot otherUserSnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: otherUserEmail)
        .get();

    if (otherUserSnapshot.docs.isNotEmpty) {
      // get the other user's ID
      String otherUserID = otherUserSnapshot.docs.first.id;

      // create a map representing the contact details
      Map<String, dynamic> contactData = {
        'email': otherUserEmail,
        'uid': otherUserID,
      };

      // add the contact to the current user's contacts
      await _firestore
          .collection('users')
          .doc(currentUserID)
          .collection('contacts')
          .doc(otherUserID)
          .set(contactData);

      // add the current user to the other user's contacts (if needed)
      /* await _firestore
        .collection('users')
        .doc(otherUserID)
        .collection('contacts')
        .doc(currentUserID)
        .set({
      'email': currentUserEmail,
    }); */
    } else {
      // handle the case where the user with the specified email was not found
      log('User with email $otherUserEmail not found.');
    }
  }

  // send message
  Future<void> sendMessage(String receiverID, message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // (so that the chatroomID is same for both people)
    String chatroomID = ids.join('_');

    // add new message to database
    _firestore
        .collection('chat_rooms')
        .doc(chatroomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatroomID = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatroomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
