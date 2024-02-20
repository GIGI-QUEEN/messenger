import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secure_messenger/components/last_message.dart';
import 'package:secure_messenger/pages/chats_page/chats_list.dart';
import 'package:secure_messenger/services/auth/auth_service.dart';
import 'package:secure_messenger/services/chat/chat_service.dart';

import '../components/my_drawer.dart';
import '../components/user_tile.dart';
import 'chat_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// chat and auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void logout() {
    // get auth service
    final auth = AuthService();
    auth.signOut();
  }

  void goToProfilePage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to new page
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: logout,
      ),
      body: Column(
        children: [
          /* const SizedBox(height: 20),
          const Text(
            'CONTACTS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: _buildContactList(),
          ),
          const Padding(
            padding: EdgeInsets.only(
              bottom: 30.0,
              left: 30,
              right: 30,
            ),
            child: Divider(),
          ), */
          const SizedBox(height: 20),
          const Text(
            'CHATS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ChatsList(),
          ),
          const Padding(
            padding: EdgeInsets.only(
              bottom: 30.0,
              left: 30,
              right: 30,
            ),
            child: Divider(),
          ),
          const Text(
            'ALL USERS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        // log('Snapshot Data in getUsersStream: ${snapshot.data}');

        // error
        if (snapshot.hasError) {
          return const Text('Error');
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        // return list view
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // build a list of contacts except for the current logged in user
  Widget _buildContactList() {
    return StreamBuilder(
      stream:
          _chatService.getContactsStream(_authService.getCurrentUser()!.uid),
      builder: (context, snapshot) {
        // log('Snapshot Data in getContactsStream: ${snapshot.data}');

        // error
        if (snapshot.hasError) {
          return const Text('Error');
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        // return list view
        return ListView(
          children: snapshot.data!
              .map<Widget>(
                  (userData) => _buildContactListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // build a list of contacts except for the current logged in user
  Widget _buildChatList() {
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
  }

  // build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic>? userData, BuildContext context) {
    // display all user except current user
    if (userData != null &&
        userData['uid'] != _authService.getCurrentUser()!.uid) {
      // log('userData: $userData');
      return UserTile(
        text: userData['email'],
        imageURL: userData['profile_image'] ?? '',
        subtitle: null,
        onTap:
            // tapped on a user -> go to chat page
            () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverEmail: userData['email'],
                    receiverID: userData['uid'],
                  ),
                )),
      );
    } else {
      return Container();
    }
  }

  Widget _buildContactListItem(
      Map<String, dynamic> userData, BuildContext context) {
    String chatRoomID = _chatService.constructChatRoomID(
        userData['uid'], _authService.getCurrentUser()!.uid);
    return Column(
      children: [
        UserTile(
          text: userData['email'],
          imageURL: userData['profile_image'] ?? '',
          subtitle: LastMessageDisplay(
            chatroomId: chatRoomID,
            chatService: _chatService,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData['email'],
                receiverID: userData['uid'],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildChatListItem(
      Map<dynamic, dynamic> userData, BuildContext context) {
    String chatRoomID =_chatService.constructChatRoomID(
        userData['uid'], _authService.getCurrentUser()!.uid);
    return Column(
      children: [
        UserTile(
          text: userData['email'],
          imageURL: userData['profile_image'] ?? '',
          subtitle: LastMessageDisplay(
            chatroomId: chatRoomID,
            chatService: _chatService,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData['email'],
                receiverID: userData['uid'],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
