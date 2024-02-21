import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:secure_messenger/services/database/database_service.dart';

class RoomsProvider extends ChangeNotifier {
  List<types.Room> _rooms = [];
  List<types.Room> get rooms => _rooms;
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseChatCore _chatCore = FirebaseChatCore.instance;
  final Map<String, dynamic> lastMessagesMap = {};

  void listenToUserRooms() {
    _databaseService.getUserRooms().listen((roomsStream) {
      _rooms = roomsStream;

      notifyListeners();
    });
  }

  types.User companion(types.Room room) {
    final currentUserId = _chatCore.firebaseUser!.uid;
    return room.users.firstWhere((user) => user.id != currentUserId);
  }

  RoomsProvider() {
    // fetchUser();
    listenToUserRooms();
    // getLastMessage(rooms[0]);
  }
}
