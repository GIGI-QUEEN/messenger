import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secure_messenger/services/chat/chat_service.dart';

class LastMessageDisplay extends StatelessWidget {
  final String chatroomId;
  final ChatService chatService;

  const LastMessageDisplay({
    super.key,
    required this.chatroomId,
    required this.chatService,
  });

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
          final lastMessage = lastMessageData['message'] ?? '';
          return Text(lastMessage);
        }
      },
    );
  }
}
