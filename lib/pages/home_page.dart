// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:secure_messenger/pages/profile_page/profile_page.dart';
import 'package:secure_messenger/pages/rooms_page/rooms_page.dart';
import 'package:secure_messenger/services/auth/auth_service.dart';

import '../components/custom_drawer.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// chat and auth service
  final FirebaseChatCore _firebaseChatCore = FirebaseChatCore.instance;

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
          builder: (context) => ProfilePage(
            userId: _firebaseChatCore.firebaseUser!.uid,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      drawer: CustomDrawer(
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
