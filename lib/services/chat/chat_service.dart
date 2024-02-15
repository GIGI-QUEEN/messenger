import 'package:uuid/uuid.dart';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_messenger/models/message.dart';

class ChatService {
  // get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();

        // return user
        return user;
      }).toList();
    });
  }

  // get contact stream
  Stream<List<Map<String, dynamic>>> getContactsStream(String currentUserID) {
    return _firestore
        .collection('users')
        .doc(currentUserID)
        .collection('contacts')
        .snapshots()
        .asyncMap((snapshot) async {
      final contacts = await Future.wait(snapshot.docs.map((doc) async {
        // retrieve contact information from the 'users' collection
        final contactUserID = doc.id;
        final contactData =
            await _firestore.collection('users').doc(contactUserID).get();

        // combine contact information from the 'contacts' and 'users' collections
        final contact = {
          ...doc.data(),
          'profile_image': contactData['profile_image'],
        };

        log('Contact profile_image URL: ${contact['profile_image']}');
        log('currentUserID: $currentUserID');

        return contact;
      }).toList());

      return contacts;
    });
  }

  Future getImage(String receiverID) async {
    var imageFile = File('');

    ImagePicker picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery).then((xFile) async {
      if (xFile != null) {
        imageFile = File(xFile.path);
        log(imageFile.path);
        await uploadImageOrVideo(receiverID, imageFile, Type.image);
      }
    });
  }

  Future getVideo(String receiverID) async {
    log('in getvideo');
    var videoFile = File('');

    ImagePicker picker = ImagePicker();
    await picker.pickVideo(source: ImageSource.gallery).then((xFile) async {
      if (xFile != null) {
        videoFile = File(xFile.path);
        log(videoFile.path);
        await uploadImageOrVideo(receiverID, videoFile, Type.video);
      }
    });
  }

  Future<void> uploadImageOrVideo(
      String receiverID, File file, Type type) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    String chatroomID = constructChatRoomID(currentUserID, receiverID);
    String fileName = const Uuid().v1();
    var ref = type == Type.image
        ? FirebaseStorage.instance.ref().child('images').child('$fileName')
        : FirebaseStorage.instance.ref().child('videos').child('$fileName');
    var uploadTask = type == Type.image
        ? await ref.putFile(file)
        : await ref.putFile(file, SettableMetadata(contentType: 'video/mp4'));

    log('Image/Video Size: ${file.lengthSync()}');

    String fileUrl = await uploadTask.ref.getDownloadURL();

    try {
      // create a new message
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: fileUrl,
        chatroomID: chatroomID,
        timestamp: timestamp,
        type: type,
      );

      // add new message to database
      DocumentReference messageReference = await _firestore
          .collection('chat_rooms')
          .doc(chatroomID)
          .collection('messages')
          .add(
        {
          ...newMessage.toMap(),
          'messageID': '',
        },
      );

      // update the messageID field with the actual document ID
      await messageReference.update({'messageID': messageReference.id});
    }
    // handle errors
    catch (error) {
      log('error: $error');
    }
  }

  // add profile image
  Future<void> addProfileImage(String currentUserID) async {
    // pick an image
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    //log('${image?.path}');

    if (image == null) return;

    // create a unique name
    String uniqueFileName =
        '${currentUserID}_${DateTime.now().microsecondsSinceEpoch}';
    String imageURL = '';
    try {
      // get a reference to storage root
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('profile_images/');

      // create a reference for the profile image to be stored
      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFileName);

      // upload image to storage
      await referenceImageToUpload.putFile(File(image.path));
      // get download url
      imageURL = await referenceImageToUpload.getDownloadURL();
      //log('imageURL: $imageURL');

      // update user document in storage with the new image url
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .update({'profile_image': imageURL});

      Reference httpsReference = FirebaseStorage.instance.ref(imageURL);
      log('httpsReference: $httpsReference');
      // handle errors
    } catch (error) {
      log('error: $error');
    }

    try {
      // update profile image in user's contacts
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .collection('contacts')
          .get();

      for (DocumentSnapshot ds in querySnapshot.docs) {
        String contactUserID = ds.id;
        await updateContactProfileImage(currentUserID, contactUserID, imageURL);
      }
      //log('Profile image added in contacts');
      // handle errors
    } catch (error) {
      log('Error updating profile image in contacts: $error');
    }
  }

  Future<void> updateContactProfileImage(String currentUserID,
      String contactUserID, String profileImageURL) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(contactUserID)
          .collection('contacts')
          .doc(currentUserID)
          .update({'profile_image': profileImageURL});
    } catch (error) {
      log('Error updating profile image for contact $contactUserID: $error');
    }
  }

  // add user to contacts
  Future<void> addUserToContacts(String otherUserEmail) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;

    // retrieve the other user's document based on their email
    QuerySnapshot otherUserSnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: otherUserEmail)
        .get();

    // check if the user with the specified email exists
    if (otherUserSnapshot.docs.isNotEmpty) {
      // get the other user's document
      final otherUserDocument = otherUserSnapshot.docs.first;
      // get the other user's ID
      String otherUserID = otherUserDocument.id;

      // create a map representing the contact details
      Map<String, dynamic> contactData = {
        'uid': otherUserID,
        'email': otherUserEmail,
        'username': otherUserDocument['username'],
        'bio': otherUserDocument['bio'],
        'profile_image': otherUserDocument['profile_image'],
      };

      // add the contact to the current user's contacts
      await _firestore
          .collection('users')
          .doc(currentUserID)
          .collection('contacts')
          .doc(otherUserID)
          .set(contactData);

      // add the current user to the other user's contacts (if needed)
      /* await _firestore
        .collection('users')
        .doc(otherUserID)
        .collection('contacts')
        .doc(currentUserID)
        .set({
      'email': currentUserEmail,
    }); */
    } else {
      // handle the case where the user with the specified email was not found
      log('User with email $otherUserEmail not found.');
    }
  }

  String constructChatRoomID(String currentUserID, receiverID) {
    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // (so that the chatroomID is same for both people)
    return ids.join('_');
  }

  // send message
  Future<void> sendMessage(String receiverID, message) async {
    log('message is: $message');
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    String chatroomID = constructChatRoomID(currentUserID, receiverID);
    log('chatroomid: $chatroomID');

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      chatroomID: chatroomID,
      timestamp: timestamp,
      type: Type.text,
    );

    // add new message to database
    DocumentReference messageReference = await _firestore
        .collection('chat_rooms')
        .doc(chatroomID)
        .collection('messages')
        .add(
      {
        ...newMessage.toMap(),
        'messageID': '',
      },
    );
    // update the messageID field with the actual document ID
    await messageReference.update({'messageID': messageReference.id});
  }

  Future<void> changeMessage(String chatroomID, messageID, newMessage) async {
    try {
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatroomID)
          .collection('messages')
          .doc(messageID)
          .update({'message': newMessage});
    } catch (e) {
      log('Error deleting message: $e');
    }
  }

  Future<void> deleteMessage(String chatroomID, messageID) async {
    try {
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatroomID)
          .collection('messages')
          .doc(messageID)
          .delete();
    } catch (e) {
      log('Error deleting message: $e');
    }
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construct a chatroom ID for the two users
    String chatroomID = constructChatRoomID(userID, otherUserID);

    return _firestore
        .collection('chat_rooms')
        .doc(chatroomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // get the stream of the last message in the conversation
  Stream<DocumentSnapshot?> getLastMessageStream(String chatroomId) {
    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      } else {
        return null;
      }
    });
  }
}
