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

  void updateMessageStatus(String roomId, String messageId) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({
      'metadata': {'isSeen': true}
    });
  }

  void addUserToContacts(String userId, String contactId) async {
    await _firestore.collection('users').doc(userId).update({
      'contacts': FieldValue.arrayUnion([contactId])
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

  /* void isContact(String userId, String contactId) async {
    await _firestore.collection('users').doc(userId).ge
  } */
}
