import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class DatabaseService {
  final _chatCore = FirebaseChatCore.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<types.User>> getAllUsers() {
    return _chatCore.users();
  }

  Stream<List<types.Room>> getUserRooms() {
    return _chatCore.rooms(orderByUpdatedAt: true);
  }

  void updateLastMessage(String roomId, String lastMessageText) {
    _firestore.collection('rooms').doc(roomId).update({
      'lastMessage': lastMessageText,
    });
  }

  Stream<String> getLastMessage(String roomid) {
    return _firestore
        .collection('rooms')
        .doc(roomid)
        .snapshots()
        .asyncMap((snapshot) {
      final Map<String, dynamic> data = snapshot.data() as dynamic;
      return data['lastMessage'];
    });
  }

/*   Future<types.User> getUserById(String id) async {
    // types.User user = types.User(id: id);
    return await _firestore.collection('users').doc(id).get().then((snapshot) {
      final data = Map<String, dynamic>.from(snapshot.data() as dynamic);
      types.User user = types.User(id: id, imageUrl: data['imageUrl']);
      /* data.forEach((key, value) {
      //  user = value;
      },); */
      // types.User user = types.User(id: id);
      //log(user.toString());
      return user;
    });
    //return user;
  } */
}
