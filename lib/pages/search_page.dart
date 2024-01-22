import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secure_messenger/components/my_textfield.dart';

import '../components/my_button.dart';
import '../services/auth/auth_service.dart';
import '../services/chat/chat_service.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  late bool contactNotFound = false;

  // text controller
  final TextEditingController _searchController = TextEditingController();

  // chat and auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void searchUsers() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await firestore
        .collection('users')
        .where('email', isEqualTo: _searchController.text)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
          contactNotFound = false;
        });
        log(userMap.toString());
      } else {
        setState(() {
          userMap = null;
          isLoading = false;
          contactNotFound = true;
          _searchController.text = '';
        });
        log('No users found');
      }
    });
  }

  // add contact
  void addContact() async {
    await _chatService.addUserToContacts(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Center(
              child: Column(
                children: [
                  // search textfield
                  MyTextField(
                    controller: _searchController,
                    hintText: 'Search',
                    obscureText: false,
                  ),

                  const SizedBox(height: 25),

                  // search button
                  MyButton(onTap: () => searchUsers(), text: 'Search'),

                  if (isLoading)
                    Center(
                      child: Container(
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  else if (contactNotFound)
                    const Text('No users with search criteria')
                  else if (userMap != null)
                    ListTile(
                      onTap: () {},
                      leading:
                          const Icon(Icons.account_box, color: Colors.grey),
                      title: Text(
                        userMap!['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(userMap!['email'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => addContact(),
                            child: const Icon(Icons.add, color: Colors.grey),
                          ),
                          /* const SizedBox(width: 8),
                                       GestureDetector(
                                        onTap: () => {log('send a message')},// maybe todo later: open chat window
                                        child: const Icon(Icons.chat, color: Colors.grey),
                                      ), */
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
