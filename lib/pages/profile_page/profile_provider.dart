import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:secure_messenger/services/database/database_service.dart';
import 'package:secure_messenger/services/media/media_service.dart';

class ProfileProvider extends ChangeNotifier {
  final String userId;

  User _user = const User(id: '');
  User get user => _user;
  bool _isContact = false;
  bool get isContact => _isContact;

  bool _isCurrentUserProfile = false;
  bool get isCurrentUserProfile => _isCurrentUserProfile;

  //PROFILE EDITING
  bool _isEditing = false;
  bool get isEditing => _isEditing;
  File? _image;

  //SERVICES
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseChatCore _firebaseChatCore = FirebaseChatCore.instance;
  final MediaService _mediaService = MediaService();

  void fetchUserData() async {
    final userData = await _databaseService.getUserById(userId);
    _user = User.fromJson(userData);
    if (_user.id == _firebaseChatCore.firebaseUser!.uid) {
      _isCurrentUserProfile = true;
      notifyListeners();
    }
    checkIsContact(_user.id);
    notifyListeners();
  }

  void startEditing() {
    _isEditing = true;
    notifyListeners();
  }

  void cancelEditing() {
    _isEditing = false;
    _image = null;
    notifyListeners();
  }

  void pickImage() async {
    _image = await _mediaService.pickImage();
  }

  void saveChanges() async {
    if (_image != null) {
      final imageUrl =
          await _mediaService.uploadImage(_image!, 'profile_images');
      _databaseService.updateUserProfileImageUrl(userId, imageUrl);
      fetchUserData();
    }
    cancelEditing();
  }

  void addToContacts(String contactId) {
    _databaseService.addUserToContacts(
        _firebaseChatCore.firebaseUser!.uid, contactId);
    fetchUserData();

    //notifyListeners();
  }

  void removeFromContacts(String contactId) {
    _databaseService.removeUserFromContacts(
        _firebaseChatCore.firebaseUser!.uid, contactId);
    fetchUserData();
    //notifyListeners();
  }

  void checkIsContact(String otherUserId) async {
    _isContact = await _databaseService.isContact(
        _firebaseChatCore.firebaseUser!.uid, otherUserId);
    notifyListeners();
  }

  ProfileProvider({required this.userId}) {
    fetchUserData();
  }

  @override
  void dispose() {
    super.dispose();
    _image = null;
  }
}
