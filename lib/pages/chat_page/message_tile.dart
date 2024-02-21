import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:secure_messenger/pages/chat_page/user_input.dart';
import 'package:secure_messenger/themes/light_mode.dart';

class TextMessageTile extends StatelessWidget {
  const TextMessageTile(
      {super.key, required this.message, required this.alignment});
  final TextMessage message;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser =
        alignment == Alignment.centerRight ? true : false;
    final BorderRadius borderRadius =
        isCurrentUser ? currentUserBorderRadius : otherUserBorderUserRadius;

    return Container(
      /* height: 30,
      width: 50, */
      margin: const EdgeInsets.only(bottom: 15),
      alignment: alignment,
      //color: green,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        constraints: const BoxConstraints(minWidth: 50, minHeight: 30),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: isCurrentUser ? green : mainBlack,
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

const currentUserBorderRadius = BorderRadius.only(
  topRight: Radius.circular(10),
  topLeft: Radius.circular(10),
  bottomLeft: Radius.circular(10),
);
const otherUserBorderUserRadius = BorderRadius.only(
  topRight: Radius.circular(10),
  topLeft: Radius.circular(10),
  bottomRight: Radius.circular(10),
);
