import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secure_messenger/components/my_textbox.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection('users');

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
      await usersCollection.doc(currentUser.uid).update({field: newValue});
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

                // profile picture
                // todo: image, and a field to modify it
                const Icon(
                  Icons.person,
                  size: 72,
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
