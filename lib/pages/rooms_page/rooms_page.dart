import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/pages/chat_page/chat_page.dart';
import 'package:secure_messenger/pages/rooms_page/rooms_provider.dart';
import 'package:secure_messenger/services/database/database_service.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  appBar: AppBar(
        title: const Text('chat rooms'),
      ), */
      body: ChangeNotifierProvider(
        create: (context) => RoomsProvider(),
        child: Consumer<RoomsProvider>(
          builder: (context, model, child) {
            //log('ROOMS: ${model.rooms}');
            return ListView.builder(
              itemCount: model.rooms.length,
              itemBuilder: (context, index) {
                final room = model.rooms.elementAt(index);
                final companion = model.companion(room);
                return RoomTile(
                  room: room,
                  companion: companion,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

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
        title: Text(companion.metadata!['username']),
        leading: companion.imageUrl != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(companion.imageUrl!),
              )
            : const Icon(
                Icons.person,
              ),
        subtitle: StreamBuilder(
          stream: _databaseService.getLastMessage(room.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.toString());
            }
            return const Text('no last message');
          },
        ),
        onTap: () => navigateToChatPage(context),
      ),
    );
  }
}
