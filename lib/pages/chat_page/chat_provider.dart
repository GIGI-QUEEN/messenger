import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:secure_messenger/services/chat/chat_service.dart';
import 'package:secure_messenger/services/database/database_service.dart';
import 'package:secure_messenger/services/encryption/encryption_serivce.dart';
import 'package:secure_messenger/services/media/media_service.dart';
import 'package:video_player/video_player.dart';

class ChatProvider extends ChangeNotifier {
  final String roomId;
  bool isSecured = false;
  Room? _room;
  Room? get room => _room;
  List<Message> _messages = [];
  List<Message> get messages => _messages;
  final TextEditingController textEditingController = TextEditingController();
  late String currentUserPublicKey;
  late String currentUserPrivateKey;

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
  final ChatService _chatService = ChatService();
  final EncryptionService _encryptionService = EncryptionService();

  //STREAMS
  StreamSubscription? _roomSubscription;
  StreamSubscription? _messagesSubscription;

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
          _chatService.updateMessageStatus(roomId, _messages.elementAt(0).id);
        }
        notifyListeners();
      });

      // notifyListeners(); //not sure if it's needed
    });
    //  notifyListeners(); //not sure if it's needed
  }

  /// Exctarct companion
  User? companion() {
    final currentUserId = _firebaseChatCore.firebaseUser!.uid;
    if (room != null) {
      return room!.users.firstWhere((user) => user.id != currentUserId);
    }
    return null;
  }

  /// Decrypt text of encrypted message
  String decryptMessageText(TextMessage message) {
    final Encrypted textAsBase64ForReceiver =
        Encrypted.fromBase64(message.text);
    final Encrypted textAsBase64ForSender =
        Encrypted.fromBase64(message.metadata!['forSenderToDecrypt']);

    String decryptedText = '';

    if (message.metadata!['isEncrypted'] == true) {
      if (message.author.id == _firebaseChatCore.firebaseUser!.uid) {
        decryptedText = _decryptMessageAsSender(textAsBase64ForSender);
      } else {
        decryptedText = _decryptMessageAsReceiver(textAsBase64ForReceiver);
      }
    }
    log('decrypted text: $decryptedText');
    return decryptedText;
  }

/*   Future<String> _decryptMessageAsSender(Encrypted textAsBase64) async {
    final String senderPublicKey = await _encryptionService.getPublicKey();
    final String senderPrivateKey = await _encryptionService.getPrivateKey();
    return _encryptionService.decryptMessage(
        textAsBase64, senderPublicKey, senderPrivateKey);
  }

  Future<String> _decryptMessageAsReceiver(Encrypted textAsBase64) async {
    final String senderPublicKey = companion()?.metadata!['publicKey'];
    final String receiverPrivateKey = await _encryptionService.getPrivateKey();
    return _encryptionService.decryptMessage(
        textAsBase64, senderPublicKey, receiverPrivateKey);
  }

  /// Encrypting message so only receiver will be able to decrypt it
  Future<String> _encryptTextMessageForReceiver(String text) async {
    final senderPrivateKey = await _encryptionService.getPrivateKey();
    final receiverPublicKey = companion()!.metadata!['publicKey'];
    final encryptedText = _encryptionService.encryptMessage(
        text, receiverPublicKey, senderPrivateKey);
    return encryptedText.base64;
  }

  /// Enccrypting message so only sender will be able to see it
  Future<String> _encryptTextMessageForSender(String text) async {
    final senderPrivateKey = await _encryptionService.getPrivateKey();
    final senderPublicKey = await _encryptionService.getPublicKey();
    final encryptedText = _encryptionService.encryptMessage(
        text, senderPublicKey, senderPrivateKey);
    return encryptedText.base64;
  } */

  String _decryptMessageAsSender(Encrypted textAsBase64) {
    return _encryptionService.decryptMessage(
        textAsBase64, currentUserPublicKey, currentUserPrivateKey);
  }

  String _decryptMessageAsReceiver(Encrypted textAsBase64) {
    final String senderPublicKey = companion()?.metadata!['publicKey'];

    return _encryptionService.decryptMessage(
        textAsBase64, senderPublicKey, currentUserPrivateKey);
  }

  /// Encrypting message so only receiver will be able to decrypt it
  String _encryptTextMessageForReceiver(String text) {
    final receiverPublicKey = companion()!.metadata!['publicKey'];
    final encryptedText = _encryptionService.encryptMessage(
        text, receiverPublicKey, currentUserPrivateKey);
    return encryptedText.base64;
  }

  /// Enccrypting message so only sender will be able to see it
  String _encryptTextMessageForSender(String text) {
    final encryptedText = _encryptionService.encryptMessage(
        text, currentUserPublicKey, currentUserPrivateKey);
    return encryptedText.base64;
  }

  /// Sends encrypted message
  void _sendSecuredMessage() async {
    final encryptedTextReceiver =
        _encryptTextMessageForReceiver(textEditingController.text);
    final encryptedTextSender =
        _encryptTextMessageForSender(textEditingController.text);
    final text = PartialText(
      text: encryptedTextReceiver,
      metadata: {
        'isSeen': false,
        'isEncrypted': true,
        'forSenderToDecrypt': encryptedTextSender,
      },
    );
    _firebaseChatCore.sendMessage(text, roomId);
    textEditingController.clear();
  }

  /// Sends plain text message
  void _sendPlainTextMessage() {
    final text = PartialText(
      text: textEditingController.text,
      metadata: const {
        'isSeen': false,
        'isEncrypted': false,
      },
    );
    _firebaseChatCore.sendMessage(text, roomId);
    textEditingController.clear();
    _databaseService.updateLastMessage(roomId, text.text);
  }

  void sendTextMessage() {
    if (isSecured) {
      _sendSecuredMessage();
      return;
    }
    _sendPlainTextMessage();
  }

  void pickImage() async {
    image = await _mediaService.pickImage();
  }

  void sendImageMessage() async {
    if (image != null) {
      final imageUri = await _mediaService.uploadImage(image!, 'images');
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

  /// Sets room to secured/not secured state. When isSecret is true, all messages are encrypted
  void changeRoomSecurityStatus() {
    isSecured = !isSecured;
    notifyListeners();
  }

  void exctactCurrentUserSecurityKeys() async {
    currentUserPublicKey = await _encryptionService.getPublicKey();
    currentUserPrivateKey = await _encryptionService.getPrivateKey();
  }

  ChatProvider({required this.roomId}) {
    getRoom();
    exctactCurrentUserSecurityKeys();
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
