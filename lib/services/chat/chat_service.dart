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
        await uploadImage(receiverID, imageFile);
      }
    });
  }

  Future<void> uploadImage(String receiverID, File imageFile) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    String chatroomID = constructChatRoomID(currentUserID, receiverID);
    String fileName = const Uuid().v1();
    var ref =
        FirebaseStorage.instance.ref().child('images').child('$fileName.jpg');
    var uploadTask = await ref.putFile(imageFile);
    String imageUrl = await uploadTask.ref.getDownloadURL();

    try {
      // create a new message
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: imageUrl,
        chatroomID: chatroomID,
        timestamp: timestamp,
        type: Type.image,
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
    print('${image?.path}');

    if (image == null) return;

    // create a unique name
    String uniqueFileName =
        '${currentUserID}_${DateTime.now().microsecondsSinceEpoch}';

    // get a reference to storage root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('profile_images/');

    // create a reference for the profile image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      // upload image to storage
      await referenceImageToUpload.putFile(File(image.path));
      // get download url
      String imageURL = await referenceImageToUpload.getDownloadURL();
      log('imageURL: $imageURL');

      // update user document in storage with the new image url
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .update({'profile_image': imageURL});

      // get the download url
      Reference httpsReference = FirebaseStorage.instance.ref(imageURL);
      log('httpsReference: $httpsReference');
    }
    // handle errors
    catch (error) {
      log('error: $error');
    }

/* // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
// Capture a photo.
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
// Pick a video.
    final XFile? galleryVideo =
        await picker.pickVideo(source: ImageSource.gallery);
// Capture a video.
    final XFile? cameraVideo =
        await picker.pickVideo(source: ImageSource.camera);
// Pick multiple images.
    final List<XFile> images = await picker.pickMultiImage();
// Pick singe image or video.
    final XFile? media = await picker.pickMedia();
// Pick multiple images and videos.
    final List<XFile> medias = await picker.pickMultipleMedia(); */

    // write to database
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
}
