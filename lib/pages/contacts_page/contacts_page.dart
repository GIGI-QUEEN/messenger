import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/constants/routes.dart';
import 'package:secure_messenger/pages/chat_page/chat_page.dart';
import 'package:secure_messenger/pages/contacts_page/contact_tile.dart';
import 'package:secure_messenger/pages/contacts_page/contacts_provider.dart';
import 'package:secure_messenger/utils/navigation.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contacts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                navigateToNamed(context, searchPage);
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: ChangeNotifierProvider(
        create: (context) => ContactsProvider(),
        child: Consumer<ContactsProvider>(
          builder: (context, model, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ListView.builder(
                itemCount: model.users.length,
                itemBuilder: (context, index) {
                  final user = model.users[index];
                  return UserTile(
                    user: user,
                    onTap: () async {
                      final roomId = await model.startChat(user);
                      navigateTo(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(roomId: roomId)));
                    },
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
