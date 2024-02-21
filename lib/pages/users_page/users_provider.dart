import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:secure_messenger/services/database/database_service.dart';

class UsersProvider extends ChangeNotifier {
  List<types.User> _users = [];
  List<types.User> get users => _users;
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseChatCore _firebaseChatCore = FirebaseChatCore.instance;

  void listenToUsers() {
    _databaseService.getAllUsers().listen((event) {
      _users = event;
      log(_users.toString());
      notifyListeners();
    });
  }

  Future<String> startChat(types.User otherUser) async {
    final room = await _firebaseChatCore.createRoom(otherUser);
    return room.id;
  }

  UsersProvider() {
    listenToUsers();
  }
}
