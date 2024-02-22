import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/border_radius.dart';
import 'package:secure_messenger/pages/chat_page/user_input.dart';
import 'package:secure_messenger/themes/light_mode.dart';

class ImageMessageTile extends StatelessWidget {
  const ImageMessageTile(
      {super.key, required this.message, required this.alignment});
  final ImageMessage message;
  final Alignment alignment;
  @override
  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser =
        alignment == Alignment.centerRight ? true : false;
    final BorderRadius borderRadius =
        isCurrentUser ? currentUserBorderRadius : otherUserBorderUserRadius;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        constraints: const BoxConstraints(
            minWidth: 50, minHeight: 30, maxHeight: 250, maxWidth: 200),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: isCurrentUser ? green : mainBlack,
        ),
        child: Image(
          image: NetworkImage(message.uri),
        ),
      ),
    );
  }
}
