import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class ChatServiceV2 {
  final FirebaseChatCore _chatCore = FirebaseChatCore.instance;

  void sendMessage(dynamic message, String roomId) {
    _chatCore.sendMessage(message, roomId);
  }
}
