import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:secure_messenger/models/chatroom.dart';
import 'package:secure_messenger/services/auth/auth_service.dart';
import 'package:secure_messenger/services/chat/chat_service.dart';

class ChatsProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  List <ChatRoom> _chats = [];

  List get chats => _chats;

  ChatService _chatService = ChatService();

  // funkcija, kotoraja sozdaet strim i slushaet i
  // poluchaet dannye s pomoshju getChatRoomsStream

  getChats() {
   /*  _chatService
        .getChatRoomsStream(_authService.getCurrentUser()!.uid)
        .listen((event) {
      log("event: ${event}");

    }); */
    //_chatService.getChatRoomsStream(_authService.getCurrentUser()!.uid);
    _chatService.getChatRoomsV3((_authService.getCurrentUser()!.uid)).listen((event) {
      log('EVENT: $event');
    });
  }

  ChatsProvider() {
    //start listening to chats
    getChats();
  }
}
