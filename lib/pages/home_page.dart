// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secure_messenger/components/last_message.dart';
import 'package:secure_messenger/pages/rooms_page/rooms_page.dart';
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: logout,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: RoomsPage(),
      ),
    );
  }
}
