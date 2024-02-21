import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/pages/chat_page/chat_page.dart';
import 'package:secure_messenger/pages/users_page/users_provider.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => UsersProvider(),
        child: Consumer<UsersProvider>(
          builder: (context, model, _) {
            return Center(
              child: ListView.builder(
                itemCount: model.users.length,
                itemBuilder: (context, index) {
                  final user = model.users[index];
                  //log(user.id);
                  return Row(
                    children: [
                      Text(user.metadata!['email']),
                      /* OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChatPage(roomId: roomId)));
                          },
                          child: const Text('go to chat')), */
                      OutlinedButton(
                          onPressed: () async {
                            final roomId = await model.startChat(user);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChatPage(roomId: roomId)));
                          },
                          child: const Text('start chat'))
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
