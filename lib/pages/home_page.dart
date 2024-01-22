import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:secure_messenger/services/auth/auth_service.dart';
import 'package:secure_messenger/services/chat/chat_service.dart';

import '../components/my_drawer.dart';
import '../components/user_tile.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

// chat and auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

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
      drawer: const MyDrawer(),
      body: Column(children: [
        const SizedBox(height: 20),

        // user's contact list
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
        ),

        // all users
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
      ]),
    );
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        log('Snapshot Data in getUsersStream: ${snapshot.data}');

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
        log('Snapshot Data in getContactsStream: ${snapshot.data}');

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

  // build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // display all user except current user
    if (userData['uid'] != _authService.getCurrentUser()!.uid) {
      log('userData: $userData');
      return UserTile(
        text: userData['email'],
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

  // build individual list tile for user
  Widget _buildContactListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // display all users except current user
    if (userData['email'] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData['email'],
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
}
