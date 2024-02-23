import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/pages/chat_page/chat_provider.dart';
import 'package:secure_messenger/pages/chat_page/message_list.dart';
import 'package:secure_messenger/pages/chat_page/user_input.dart';
import 'package:secure_messenger/themes/light_mode.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key, required this.roomId});
  final String roomId;
  /*  final TextEditingController _textEditingController = TextEditingController();
  final FirebaseChatCore _chatCore = FirebaseChatCore.instance; */
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(roomId: roomId),
      child: Consumer<ChatProvider>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: darkMode.colorScheme.background,
              title: Text(model.companion() != null
                  ? model.companion()!.metadata!['username']
                  : 'loading'),
            ),
            body: Container(
              // padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Column(children: [
                Expanded(child: MessagesList(messages: model.messages)),
                UserInput(),
              ]),
            ),
          );
        },
      ),
    );
  }
}
