import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:secure_messenger/components/avatar.dart';
import 'package:secure_messenger/pages/chat_page/chat_page.dart';
import 'package:secure_messenger/services/database/database_service.dart';
import 'package:secure_messenger/themes/light_mode.dart';

class RoomTile extends StatelessWidget {
  RoomTile({super.key, required this.room, required this.companion});
  final Room room;
  final User companion;
  final DatabaseService _databaseService = DatabaseService();

  void navigateToChatPage(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ChatPage(roomId: room.id)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 245, 245, 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        title: Text(
          companion.metadata!['username'],
          style: const TextStyle(color: Colors.black),
        ),
        leading: UserAvatar(
          imageUrl: companion.imageUrl,
        ),
        subtitle: StreamBuilder(
          stream: _databaseService.getLastMessage(room.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                snapshot.data.toString(),
                style:
                    const TextStyle(color: Color.fromARGB(255, 121, 121, 121)),
              );
            }
            return const Text(
              'no last message',
              style: const TextStyle(color: Color.fromARGB(255, 121, 121, 121)),
            );
          },
        ),
        onTap: () => navigateToChatPage(context),
      ),
    );
  }
}
