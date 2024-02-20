import 'package:secure_messenger/models/message.dart';

class ChatRoom {
  final String id;
  final String otherUserId;
  final List<Message> messages;

  ChatRoom({
    required this.id,
    required this.otherUserId,
    required this.messages,
  });
}
