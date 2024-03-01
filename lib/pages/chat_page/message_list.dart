import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/border_radius.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/message_tile.dart';
import 'package:secure_messenger/pages/chat_page/user_input.dart';
import 'package:secure_messenger/themes/light_mode.dart';

class MessagesList extends StatelessWidget {
  MessagesList({
    super.key,
    required this.messages,
    required this.roomid,
    required this.isSecured,
  });
  final List<Message> messages;
  final FirebaseChatCore _chatCore = FirebaseChatCore.instance;
  final String roomid;
  final bool isSecured;
  @override
  Widget build(BuildContext context) {
    final user = _chatCore.firebaseUser;
    final securedMessages =
        messages.where((message) => message.metadata!['isEncrypted'] == true);
    final unsecuredMessages =
        messages.where((message) => message.metadata!['isEncrypted'] == false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
      child: ListView.builder(
        reverse: true,
        itemCount:
            isSecured ? securedMessages.length : unsecuredMessages.length,
        itemBuilder: (context, index) {
          final message = isSecured
              ? securedMessages.elementAt(index)
              : unsecuredMessages.elementAt(index);
          final isCurrentUser = user!.uid == message.author.id;
          final Alignment alignment =
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
          final Color bgColor = isCurrentUser ? green : mainBlack;
          final BorderRadius borderRadius = isCurrentUser
              ? currentUserBorderRadius
              : otherUserBorderUserRadius;

          return MessageTile(
            message: message,
            alignment: alignment,
            isCurrentUser: isCurrentUser,
            bgColor: bgColor,
            borderRadius: borderRadius,
            roomId: roomid,
          );
        },
      ),
    );
  }
}
