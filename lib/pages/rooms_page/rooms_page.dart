import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/pages/rooms_page/room_tile.dart';
import 'package:secure_messenger/pages/rooms_page/rooms_provider.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RoomsProvider(),
      child: Consumer<RoomsProvider>(
        builder: (context, model, child) {
          //log('ROOMS: ${model.rooms}');
          return ListView.separated(
            itemCount: model.rooms.length,
            itemBuilder: (context, index) {
              final room = model.rooms.elementAt(index);
              final companion = model.companion(room);
              return RoomTile(
                room: room,
                companion: companion,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 10,
            ),
          );
        },
      ),
    );
  }
}
