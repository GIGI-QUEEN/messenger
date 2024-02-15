import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secure_messenger/services/chat/chat_service.dart';

class LastMessageDisplay extends StatelessWidget {
  final String chatroomId;
  final ChatService chatService;

  const LastMessageDisplay({
    Key? key,
    required this.chatroomId,
    required this.chatService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot?>(
      stream: chatService.getLastMessageStream(chatroomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Text('');
        } else {
          final lastMessageData = snapshot.data!.data() as Map<String, dynamic>;
          final messageType = lastMessageData['type'] as String?;
          Widget messageWidget;

          if (messageType == 'Type.text') {
            final lastMessage = lastMessageData['message'] ?? '';
            messageWidget = Text(lastMessage);
          } else if (messageType == 'Type.image') {
            messageWidget = const Icon(Icons.image_outlined);
          } else if (messageType == 'Type.video') {
            messageWidget = const Icon(Icons.video_library_outlined);
          } else {
            messageWidget = const Text('Unknown message type');
          }

          return messageWidget;
        }
      },
    );
  }
}
