import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secure_messenger/pages/rooms_page/rooms_page.dart';
import 'package:secure_messenger/pages/users_page/users_page.dart';
import 'package:secure_messenger/services/auth/login_or_register.dart';

import 'home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // user is logged in
        if (snapshot.hasData) {
          return HomePage();
          //return UsersPage();
          // return RoomsPage();
        }
        // user is not logged in
        else {
          return const LoginOrRegister();
        }
      },
    ));
  }
}
