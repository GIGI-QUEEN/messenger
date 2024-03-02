import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class DatabaseService {
  final _chatCore = FirebaseChatCore.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<types.User>> getAllUsers() {
    return _chatCore.users();
  }

  Stream<List<types.Room>> getUserRooms() {
    return _chatCore.rooms(orderByUpdatedAt: true);
  }

  void updateLastMessage(String roomId, String lastMessageText) {
    _firestore.collection('rooms').doc(roomId).update({
      'lastMessage': lastMessageText,
    });
  }

  Stream<String> getLastMessage(String roomid) {
    return _firestore
        .collection('rooms')
        .doc(roomid)
        .snapshots()
        .asyncMap((snapshot) {
      final Map<String, dynamic> data = snapshot.data() as dynamic;
      return data['lastMessage'];
    });
  }

  void addUserToContacts(String userId, String contactId) async {
    await _firestore.collection('users').doc(userId).update({
      'contacts': FieldValue.arrayUnion([contactId])
    });
  }

  void removeUserFromContacts(String userId, String contactId) async {
    await _firestore.collection('users').doc(userId).update({
      'contacts': FieldValue.arrayRemove([contactId])
    });
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    return await fetchUser(_firestore, userId, 'users');
  }

  Future<List<dynamic>> getContacts(String userId) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .get()
        .then((snapshot) {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(snapshot.data() as dynamic);
      return data['contacts'] as List<dynamic>;
    });
  }

  Future<bool> isContact(String userId, String otherUserId) async {
    return await _firestore.collection('users').doc(userId).get().then((doc) {
      if (doc.exists) {
        final List<dynamic> contacts = doc.data()!['contacts'] as List<dynamic>;
        final List<String> stringContacts =
            contacts.map((contact) => contact.toString()).toList();
        if (stringContacts.contains(otherUserId)) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    });
  }

  Future<String?> getUserByUsernameOrEmail(String enteredName) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where(Filter.or(Filter('metadata.email', isEqualTo: enteredName),
            Filter('metadata.username', isEqualTo: enteredName)))
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.elementAt(0);
      return doc.id;
    }
    return null;
  }

  void updateUserProfileImageUrl(String userId, String imageUrl) async {
    await _firestore.collection('users').doc(userId).update({
      'imageUrl': imageUrl,
    });
  }

  Future<String?> getUserProfileImageUrl(String userId) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .get()
        .then((snapshot) {
      final data = Map<String, dynamic>.from(snapshot.data() as dynamic);
      return data['imageUrl'] as String;
    });
  }
}
