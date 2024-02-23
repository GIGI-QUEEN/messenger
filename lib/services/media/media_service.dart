import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class MediaService {
  Future<File> pickImage() async {
    File imageFile = File('');

    ImagePicker picker = ImagePicker();
    return await picker
        .pickImage(source: ImageSource.gallery)
        .then((xFile) async {
      if (xFile != null) {
        imageFile = File(xFile.path);
        return imageFile;
      }
      throw Error();
    });
  }

  Future<File> pickVideo() async {
    File videoFile = File('');

    ImagePicker picker = ImagePicker();
    return await picker
        .pickVideo(source: ImageSource.gallery)
        .then((xFile) async {
      if (xFile != null) {
        videoFile = File(xFile.path);
        return videoFile;
      }
      throw Error();
    });
  }

  Future<String> uploadImage(File image) async {
    String fileName = const Uuid().v1();

    final imageRef =
        FirebaseStorage.instance.ref().child('images').child(fileName);
    final task = await imageRef.putFile(image);
    return task.ref.getDownloadURL();
    //String fileUrl = await uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadVideo(File image) async {
    String fileName = const Uuid().v1();

    final videoRef =
        FirebaseStorage.instance.ref().child('videos').child(fileName);
    final task = await videoRef.putFile(
        image, SettableMetadata(contentType: 'video/mp4'));
    return task.ref.getDownloadURL();
  }

/*    Future<void> uploadImageOrVideo(
      String receiverID, File file, Type type) async {
    /*  final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!; */
    final Timestamp timestamp = Timestamp.now();

    // String chatroomID = constructChatRoomID(currentUserID, receiverID);
    String fileName = const Uuid().v1();
    var ref = type == Type.image
        ? FirebaseStorage.instance.ref().child('images').child('$fileName')
        : FirebaseStorage.instance.ref().child('videos').child('$fileName');
    var uploadTask = type == Type.image
        ? await ref.putFile(file)
        : await ref.putFile(file, SettableMetadata(contentType: 'video/mp4'));

    // log('Image/Video Size: ${file.lengthSync()}');

    String fileUrl = await uploadTask.ref.getDownloadURL();

    /*    try {
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
          'id': '',
        },
      );

      // update the message id field with the actual document ID
      await messageReference.update({'id': messageReference.id});
    } */
    // handle errors
/*     catch (error) {
      log('error: $error');
    } */
  } */
}
