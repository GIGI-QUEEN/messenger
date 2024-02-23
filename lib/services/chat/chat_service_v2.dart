import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class ChatServiceV2 {
  final FirebaseChatCore _chatCore = FirebaseChatCore.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendMessage(dynamic message, String roomId) {
    _chatCore.sendMessage(message, roomId);
  }

  // delete message
  Future<void> deleteMessage(String roomId, String messageID) async {
    try {
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .doc(messageID)
          .delete();
    } catch (e) {
      log('Error deleting message: $e');
    }
  }

  void editTextMessage(
      String roomId, String messageId, String updatedText) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({'text': updatedText});
  }
}
