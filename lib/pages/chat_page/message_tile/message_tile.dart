import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/image_message_tile.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/text_message_tile.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/video_message_tile.dart';
import 'package:secure_messenger/pages/chat_page/user_input.dart';
import 'package:secure_messenger/themes/light_mode.dart';

/* class MessageTile extends StatelessWidget {
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
} */

class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
    required this.alignment,
    required this.isCurrentUser,
    required this.borderRadius,
    required this.bgColor,
  });
  final Message message;
  final Alignment alignment;
  final bool isCurrentUser;
  final BorderRadius borderRadius;
  final Color bgColor;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 15),
        alignment: alignment,
        child: isCurrentUser
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMessageTile(message.type),
                  MessageSeenStatusIcon(isSeen: message.metadata!['isSeen'])
                ],
              )
            : _buildMessageTile(message.type));
  }

  Widget _buildMessageTile(MessageType messageType) {
    switch (messageType) {
      case MessageType.text:
        return TextMessageTile(
          message: message as TextMessage,
          borderRadius: borderRadius,
          bgColor: bgColor,
        );
      case MessageType.image:
        return ImageMessageTile(
          message: message as ImageMessage,
        );
      case MessageType.video:
        return VideoMessageTile(message: message as VideoMessage);
      default:
        return const Text('Invalid message type');
    }
  }
}

class MessageSeenStatusIcon extends StatelessWidget {
  const MessageSeenStatusIcon({
    super.key,
    required this.isSeen,
  });
  final bool isSeen;
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.done_all,
      color: isSeen ? mainBlack : Colors.grey,
      size: 18,
    );
  }
}
