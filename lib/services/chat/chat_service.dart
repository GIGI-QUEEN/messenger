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
        .asyncMap((snapshot) async {
      final contacts = await Future.wait(snapshot.docs.map((doc) async {
        // retrieve contact information from the 'users' collection
        final contactUserID = doc.id;
        final contactData =
            await _firestore.collection('users').doc(contactUserID).get();

        // combine contact information from the 'contacts' and 'users' collections
        final contact = {
          ...doc.data(),
          'profile_image': contactData['profile_image'],
        };

        return contact;
      }).toList());

      return contacts;
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

    // check if the user with the specified email exists
    if (otherUserSnapshot.docs.isNotEmpty) {
      // get the other user's document
      final otherUserDocument = otherUserSnapshot.docs.first;
      // get the other user's ID
      String otherUserID = otherUserDocument.id;

      // create a map representing the contact details
      Map<String, dynamic> contactData = {
        'uid': otherUserID,
        'email': otherUserEmail,
        'username': otherUserDocument['username'],
        'bio': otherUserDocument['bio'],
        'profile_image': otherUserDocument['profile_image'],
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

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // (so that the chatroomID is same for both people)
    String chatroomID = ids.join('_');

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      chatroomID: chatroomID,
      timestamp: timestamp,
    );

    // add new message to database
    DocumentReference messageReference = await _firestore
        .collection('chat_rooms')
        .doc(chatroomID)
        .collection('messages')
        .add(
      {
        ...newMessage.toMap(),
        'messageID': '',
      },
    );
    // update the messageID field with the actual document ID
    await messageReference.update({'messageID': messageReference.id});
  }

  Future<void> deleteMessage(String chatroomID, messageID) async {
    try {
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatroomID)
          .collection('messages')
          .doc(messageID)
          .delete();
    } catch (e) {
      log('Error deleting message: $e');
    }
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
