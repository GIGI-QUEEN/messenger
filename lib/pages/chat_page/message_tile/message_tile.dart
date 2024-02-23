import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/image_message_tile.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/text_message_tile.dart';
import 'package:secure_messenger/pages/chat_page/message_tile/video_message_tile.dart';
import 'package:secure_messenger/pages/chat_page/user_input.dart';
import 'package:secure_messenger/services/chat/chat_service_v2.dart';
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
  MessageTile({
    super.key,
    required this.message,
    required this.alignment,
    required this.isCurrentUser,
    required this.borderRadius,
    required this.bgColor,
    required this.roomId,
  });
  final Message message;
  final Alignment alignment;
  final bool isCurrentUser;
  final BorderRadius borderRadius;
  final Color bgColor;
  final String roomId;
  final ChatServiceV2 _chatService = ChatServiceV2();
  // final TextEditingController _textEditingController = TextEditingController.fromValue(TextEditingValue(text: (message as TextMessage).text));
  @override
  Widget build(BuildContext context) {
    final isEditMessageDisabled = message.type == MessageType.text
        ? false
        : true; // to prevent editing image/video messages, since I'm lazy atm to develop editing functional for those messages
    return Container(
        margin: const EdgeInsets.only(bottom: 15),
        alignment: alignment,
        child: isCurrentUser
            ? GestureDetector(
                onLongPress: () => showDialog(
                    context: context,
                    builder: (context) => Dialog(
                          insetPadding: const EdgeInsets.all(130),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                onPressed: !isEditMessageDisabled
                                    ? () => showDialog(
                                          context: context,
                                          builder: (context) =>
                                              EditMessageField(
                                                  roomId: roomId,
                                                  message:
                                                      message as TextMessage),
                                        )
                                    : null,
                                icon: Icon(
                                  Icons.edit,
                                  color: isEditMessageDisabled
                                      ? const Color.fromARGB(255, 110, 110, 110)
                                      : Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _chatService.deleteMessage(
                                      roomId, message.id);
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildMessageTile(message.type),
                    MessageSeenStatusIcon(isSeen: message.metadata!['isSeen'])
                  ],
                ),
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

class EditMessageField extends StatelessWidget {
  EditMessageField({
    super.key,
    required this.message,
    required this.roomId,
  });
  final TextMessage message;
  final String roomId;
  final ChatServiceV2 _chatServiceV2 = ChatServiceV2();
  @override
  Widget build(BuildContext context) {
    final initialText = message.text;
    final TextEditingController textEditingController =
        TextEditingController.fromValue(TextEditingValue(text: initialText));
    return Dialog(
      child: TextField(
        controller: textEditingController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              color: Colors.white,
              onPressed: () {
                _chatServiceV2.editTextMessage(
                    roomId, message.id, textEditingController.text);
                Navigator.pop(context);
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            )),
      ),
    );
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
