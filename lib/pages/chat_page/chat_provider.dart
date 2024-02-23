import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:secure_messenger/services/database/database_service.dart';
import 'package:secure_messenger/services/media/media_service.dart';
import 'package:video_player/video_player.dart';

class ChatProvider extends ChangeNotifier {
  final String roomId;
  Room? _room;
  Room? get room => _room;
  List<Message> _messages = [];
  List<Message> get messages => _messages;
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
  StreamSubscription? _roomSubscription;
  StreamSubscription? _messagesSubscription;

  //PLAYING VIDEO
  /*  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
 */

  void getRoom() {
    _roomSubscription = _firebaseChatCore.room(roomId).listen((roomStream) {
      _room = roomStream;
      _messagesSubscription?.cancel();
      _messagesSubscription =
          _firebaseChatCore.messages(room!).listen((messagesStream) {
        _messages = messagesStream;
        //reading freshly received message if user currently at room page
        if (_messages.elementAt(0).author.id !=
            _firebaseChatCore.firebaseUser!.uid) {
          _databaseService.updateMessageStatus(
              roomId, _messages.elementAt(0).id);
        }
        notifyListeners();
      });

      // notifyListeners(); //not sure if it's needed
    });
    //  notifyListeners(); //not sure if it's needed
  }

/*   void getMessages() {
    if (room != null) {
      _messagesSubscription =
          _firebaseChatCore.messages(room!).listen((messagesStream) {
        _messages = messagesStream;
      });
    }
  } */

  User? companion() {
    final currentUserId = _firebaseChatCore.firebaseUser!.uid;
    if (room != null) {
      return room!.users.firstWhere((user) => user.id != currentUserId);
    }
    return null;
  }

  void sendTextMessage() {
    final text = PartialText(
        text: textEditingController.text, metadata: {'isSeen': false});
    _firebaseChatCore.sendMessage(text, roomId);
    textEditingController.clear();
    _databaseService.updateLastMessage(roomId, text.text);
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
      image = null;
      partialImage = null;
      _databaseService.updateLastMessage(roomId, 'image');
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
      _firebaseChatCore.sendMessage(partialVideo, roomId);
      video = null;
      partialVideo = null;
      _databaseService.updateLastMessage(roomId, 'video');
    }
  }

  ChatProvider({required this.roomId}) {
    getRoom();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _roomSubscription?.cancel();
    _messages = [];
    _room = null;
    super.dispose();
  }
}
