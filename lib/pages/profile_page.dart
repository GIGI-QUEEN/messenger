import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/my_textbox.dart';
import '../services/chat/chat_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  // chat service
    final ChatService _chatService = ChatService();

  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  
  // edit field
  Future<void> editField(String field) async {
    String newValue = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Edit $field',
          style: const TextStyle(color: Colors.grey),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.grey),
          decoration: InputDecoration(
            hintText: 'Enter new $field',
            hintStyle: const TextStyle(
              color: Colors.grey,
            ),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // cancel button
          TextButton(
              onPressed: () => {
                    newValue = '',
                    Navigator.pop(context),
                  },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              )),

          // save button
          TextButton(
              onPressed: () => Navigator.of(context).pop(newValue),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.grey),
              ))
        ],
      ),
    );

    //update in the firestore
    if (newValue.trim().isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
        title: const Text('Profile Page'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          //get user data

          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(height: 50),

                // stack to overlay the button on the top right corner of the Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile picture
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            //color: Color.fromARGB(169, 212, 191, 150),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: (userData['profile_image'] != null &&
                                    userData['profile_image'] != '')
                                ? CircleAvatar(
                                    radius: 60,
                                    backgroundImage:
                                        NetworkImage(userData['profile_image']),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 120,
                                  ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 206, 202, 202),
                                  width: 2.0,
                                )),
                            child: IconButton(
                              iconSize: 25,
                              icon: const Icon(
                                Icons.add_a_photo,
                                color: Color.fromARGB(111, 35, 124, 168),
                              ),
                              onPressed: () {
                                _chatService.addProfileImage(currentUser.uid);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // user email
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),

                const SizedBox(height: 50),

                // user details
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

                // username
                MyTextBox(
                  text: userData['username'],
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),

                MyTextBox(
                  text: userData['bio'],
                  sectionName: 'bio',
                  onPressed: () => editField('bio'),
                ),

                // contact list
                //MyTextBox(text: 'text', sectionName: sectionName)

                // todo: qr code button here?
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
