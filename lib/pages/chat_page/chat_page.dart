import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/components/avatar.dart';
import 'package:secure_messenger/pages/chat_page/chat_provider.dart';
import 'package:secure_messenger/pages/chat_page/message_list.dart';
import 'package:secure_messenger/pages/chat_page/user_input.dart';
import 'package:secure_messenger/themes/light_mode.dart';
import 'package:secure_messenger/utils/navigation.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.roomId});
  final String roomId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(roomId: roomId),
      child: Consumer<ChatProvider>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: () =>
                      navigatoToProfilePage(context, model.companion()!.id),
                  icon: UserAvatar(
                    imageUrl: model.companion()?.imageUrl,
                    iconColor: Colors.white,
                    iconBorderColor: Colors.white,
                    iconSize: 30,
                  ),
                ),
                IconButton(
                    onPressed: () => model.changeRoomSecurityStatus(),
                    icon: Icon(model.isSecured ? Icons.lock : Icons.lock_open))
              ],
              centerTitle: true,
              backgroundColor: darkMode.colorScheme.background,
              title: Text(model.companion() != null
                  ? model.companion()!.metadata!['username']
                  : 'loading'),
            ),
            body: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Column(children: [
                Expanded(
                  child: MessagesList(
                    messages: model.messages,
                    roomid: model.roomId,
                    isSecured: model.isSecured,
                  ),
                ),
                UserInput(),
              ]),
            ),
          );
        },
      ),
    );
  }
}
