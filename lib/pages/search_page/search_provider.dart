import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:secure_messenger/services/database/database_service.dart';

class SearchProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  TextEditingController textEditingController = TextEditingController();
  User? _foundUser;
  User? get foundUser => _foundUser;
  bool _isNotFound = false;
  bool get isNotFound => _isNotFound;

  void findUser() async {
    final userId = await _databaseService
        .getUserByUsernameOrEmail(textEditingController.text);
    if (userId != null) {
      final userData = await _databaseService.getUserById(userId);
      final user = User.fromJson(userData);
      _foundUser = user;
      notifyListeners();
    } else {
      _isNotFound = true;
      notifyListeners();
    }
    // log('USER DATA: $userData');
  }
}
