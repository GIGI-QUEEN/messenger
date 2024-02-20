  
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/providers/chats_provider.dart';

class ChatsList extends StatelessWidget {
  const ChatsList({super.key});

  @override
  Widget build(BuildContext context) {
    final chatsModel = Provider.of<ChatsProvider>(context);
   
    return Scaffold();
  }
}
  
  
 /*  Widget _buildChatList() {
    log('in _buildChatsList');
    return StreamBuilder(
      stream:
          _chatService.getChatRoomsStream(_authService.getCurrentUser()!.uid),
      builder: (context, snapshot) {
        //log('Snapshot Data in getChatRoomsStream: ${snapshot.data}');

        // error
        if (snapshot.hasError) {
          log('{$snapshot.error}');
          return const Text('Error');
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        // return list view
        return snapshot.data == null || snapshot.data!.isEmpty
            ? const Text('No chat rooms found yet.\n\n You can change that :)')
            : ListView(
                children: snapshot.data!
                    .map<Widget>(
                        (userData) => _buildChatListItem(userData, context))
                    .toList(),
              );
      },
    );
  } */