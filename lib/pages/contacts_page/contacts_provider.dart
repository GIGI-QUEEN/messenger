import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:secure_messenger/services/database/database_service.dart';

class ContactsProvider extends ChangeNotifier {
  final List<types.User> _contacts = [];
  List<types.User> get contacts => _contacts;
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseChatCore _firebaseChatCore = FirebaseChatCore.instance;

  Future<String> startChat(types.User otherUser) async {
    final room = await _firebaseChatCore.createRoom(otherUser);
    _databaseService.addTypingStatusSubcollection(
        room.id, _firebaseChatCore.firebaseUser!.uid);
    _databaseService.addTypingStatusSubcollection(room.id, otherUser.id);
    return room.id;
  }

  void addToContacts(String contactId) {
    _databaseService.addUserToContacts(
        _firebaseChatCore.firebaseUser!.uid, contactId);
  }

  void fetchContacts() async {
    final contacts =
        await _databaseService.getContacts(_firebaseChatCore.firebaseUser!.uid);
    for (final contactId in contacts) {
      final userData = await _databaseService.getUserById(contactId as String);
      final user = types.User.fromJson(userData);
      _contacts.add(user);
      notifyListeners();
    }
  }

  ContactsProvider() {
    fetchContacts();
  }
}
