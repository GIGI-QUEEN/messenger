import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class ChatService {
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

  //edit text message
  void editTextMessage(
      String roomId, String messageId, String updatedText) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({'text': updatedText});
  }

  //set message status to seen | probably might {metadata: {isSeen: bool}} should be changed to built-in satus field
  void updateMessageStatus(String roomId, String messageId) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({'metadata.isSeen': true});
  }
}
