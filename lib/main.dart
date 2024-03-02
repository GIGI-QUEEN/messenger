import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:secure_messenger/constants/routes.dart';
import 'package:secure_messenger/pages/auth_page.dart';
import 'package:secure_messenger/firebase_options.dart';
import 'package:secure_messenger/pages/contacts_page/contacts_page.dart';
import 'package:secure_messenger/pages/qr_page/qr_code_page.dart';
import 'package:secure_messenger/pages/search_page/search_page.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(), // const GenerateQRCode()
      theme: darkMode,
      routes: {
        searchPage: (context) => const SearchPage(),
        contactsPage: (context) => const ContactsPage(),
        qrPage: (context) => const QRCodePage(),
      },
    );
  }
}
