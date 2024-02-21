import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:secure_messenger/services/database/database_service.dart';

class ChatProvider extends ChangeNotifier {
  final String roomId;
  types.Room? _room;
  types.Room? get room => _room;
  List<types.Message> _messages = [];
  List<types.Message> get messages => _messages;
  String _roomTitle = '';
  String get roomTitle => _roomTitle;
  final TextEditingController textEditingController = TextEditingController();

  final FirebaseChatCore _firebaseChatCore = FirebaseChatCore.instance;
  final DatabaseService _databaseService = DatabaseService();

  late StreamSubscription _roomSubscription;
  late StreamSubscription _messagesSubscription;

  void getRoom() {
    _roomSubscription = _firebaseChatCore.room(roomId).listen((roomStream) {
      _room = roomStream;
      _messagesSubscription =
          _firebaseChatCore.messages(room!).listen((messagesStream) {
        _messages = messagesStream;
        notifyListeners();
      });
      notifyListeners(); //not sure if it's needed
    });
  }

  types.User? companion() {
    final currentUserId = _firebaseChatCore.firebaseUser!.uid;
    if (room != null) {
      return room!.users.firstWhere((user) => user.id != currentUserId);
    }
    return null;
  }

  void sendMessage(dynamic message) {
    _firebaseChatCore.sendMessage(message, roomId);
    // _firebaseChatCore.updateRoom(_room!);
  }
  /*  void sendMessage(types.PartialText message) {
    _firebaseChatCore.sendMessage(message, roomId);
    // _firebaseChatCore.updateRoom(_room!);
    _databaseService.updateLastMessage(roomId, message.text);
  } */

/*   void getMessages() {
    if (room != null) {
      _firebaseChatCore.messages(_room!);
      notifyListeners();
    }
  } */

  ChatProvider({required this.roomId}) {
    getRoom();
  }

  @override
  void dispose() {
    super.dispose();
    _roomSubscription.cancel();
    _messagesSubscription.cancel();
  }
}
