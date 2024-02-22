import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_messenger/services/database/database_service.dart';
import 'package:secure_messenger/services/media/media_service.dart';

class ChatProvider extends ChangeNotifier {
  final String roomId;
  Room? _room;
  Room? get room => _room;
  List<Message> _messages = [];
  List<Message> get messages => _messages;
  String _roomTitle = '';
  String get roomTitle => _roomTitle;
  final TextEditingController textEditingController = TextEditingController();

  //IMAGE MESSAGE
  File? image;
  PartialImage? partialImage;

  //VIDEO MESSAGE
  File? video;
  PartialVideo? partialVideo;

  //SERVICES
  final FirebaseChatCore _firebaseChatCore = FirebaseChatCore.instance;
  final DatabaseService _databaseService = DatabaseService();
  final MediaService _mediaService = MediaService();

  //STREAMS
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

  User? companion() {
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

  void pickImage() async {
    image = await _mediaService.pickImage();
  }

  void sendImageMessage() async {
    if (image != null) {
      final imageUri = await _mediaService.uploadImage(image!);
      partialImage = PartialImage(
          name: '',
          size: image!.lengthSync(),
          uri: imageUri,
          metadata: const {
            'isSeen': false,
          });
      _firebaseChatCore.sendMessage(partialImage, roomId);
    }
  }

  void pickVideo() async {
    video = await _mediaService.pickVideo();
  }

  void sendVideoMessage() async {
    if (video != null) {
      final videoUri = await _mediaService.uploadVideo(video!);

      partialVideo = PartialVideo(
        name: '',
        size: video!.lengthSync(),
        uri: videoUri,
        metadata: const {
          'isSeen': false,
        },
      );

      log(partialVideo!.uri);
      //log(video!.lengthSync().toString());
      //log(videoUri);
      _firebaseChatCore.sendMessage(partialVideo, roomId);
    }
  }

/*   void handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );
    if (result != null) {
      final bytes = await result.readAsBytes();
      // final image = await decodeImageFromList(bytes);

      partialImage =
          PartialImage(name: '', size: bytes.length, uri: result.path);
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
