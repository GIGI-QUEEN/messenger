import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/pages/auth_page.dart';
import 'package:secure_messenger/firebase_options.dart';
import 'package:secure_messenger/providers/chats_provider.dart';
import 'package:secure_messenger/themes/light_mode.dart';

// import 'services/qr/generate_qr_code.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //log('building app');
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ChatsProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthPage(), // const GenerateQRCode()
        theme: lightMode,
      ),
    );
  }
}
