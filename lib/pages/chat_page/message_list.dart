import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/message_tile.dart';

class MessagesList extends StatelessWidget {
  MessagesList({super.key, required this.messages});
  final List<Message> messages;
  final FirebaseChatCore _chatCore = FirebaseChatCore.instance;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
      child: ListView.builder(
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages.elementAt(index);
          final Alignment alignment =
              _chatCore.firebaseUser!.uid == message.author.id
                  ? Alignment.centerRight
                  : Alignment.centerLeft;
          // log('status: ${message.status}');
          //log('type: ${message.type}');
          return MessageTile(message: message, alignment: alignment);
          /* return TextMessageTile(
            message: message,
            alignment: alignment,
          ); */
        },
      ),
    );
  }
}
