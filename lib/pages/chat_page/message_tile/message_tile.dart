import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/image_message_tile.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/text_message_tile.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/video_message_tile.dart';
import 'package:secure_messenger/pages/chat_page/user_input.dart';
import 'package:secure_messenger/themes/light_mode.dart';

class MessageTile extends StatelessWidget {
  const MessageTile(
      {super.key, required this.message, required this.alignment});
  final Message message;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return TextMessageTile(
            message: message as TextMessage, alignment: alignment);
      case MessageType.image:
        return ImageMessageTile(
          message: message as ImageMessage,
          alignment: alignment,
        );
      case MessageType.video:
        return VideoMessageTile(message: message as VideoMessage);
      default:
        return Text('ERROR');
    }
  }
}
