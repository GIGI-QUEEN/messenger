import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:secure_messenger/components/chat_bubble.dart';
import 'package:secure_messenger/components/my_textfield.dart';
import 'package:secure_messenger/components/image_bubble.dart';
import 'package:secure_messenger/services/auth/auth_service.dart';
import 'package:secure_messenger/services/chat/chat_service.dart';

import '../components/video_bubble.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // scroll controller
  final ScrollController _scrollController = ScrollController();

  // chat and auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // current user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // for textfield focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // cause a delay so that the keyboard has time to show up
        // then the amount of remaining space will be calculated
        // then scroll down
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    // wait a bit for listview to be built, then scroll to bottom
    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);

      // clear text controller
      _messageController.clear();
    }

    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  // send image
  void sendImage() async {
    await _chatService.getImage(widget.receiverID);

    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  // send image
  void sendVideo() async {
    log('in sendvideo');
    await _chatService.getVideo(widget.receiverID);

    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  void deleteMessage(String chatroomID, messageID) async {
    await _chatService.deleteMessage(chatroomID, messageID);
  }

  void changeMessage(String chatroomID, messageID, newMessage) async {
    await _chatService.changeMessage(chatroomID, messageID, newMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Center(child: Text(widget.receiverEmail)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          // user input
          _buildUserInput(),
        ],
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            bool isCurrentUser = data['senderID'] == currentUser.uid;
            if (!isCurrentUser && !data['read']) {
              _chatService.markMessageAsRead(data['chatroomID'], doc.id);
            }
            return _buildMessageItem(doc);
          }).toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //

    // is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    // align messages to the right if sender is the current user, otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    log('message: ${data['message']}');
    return Container(
      alignment: alignment,
      child: Column(
        children: [
          data['type'] == 'Type.text'
              ? ChatBubble(
                  message: data['message'],
                  id: data['id'],
                  chatroomID: data['chatroomID'],
                  isCurrentUser: isCurrentUser,
                  read: data['read'],
                  onDelete: () => deleteMessage(
                    data['chatroomID'],
                    data['id'],
                  ),
                  onChange: (newMessage) => changeMessage(
                    data['chatroomID'],
                    data['id'],
                    newMessage,
                  ),
                )
              : data['type'] == 'Type.image'
                  ? ImageBubble(
                      message: data['message'],
                      isCurrentUser: isCurrentUser,
                      id: data['id'],
                      chatroomID: data['chatroomID'],
                      read: data['read'],
                      onDelete: () => deleteMessage(
                        data['chatroomID'],
                        data['id'],
                      ),
                    )
                  : VideoBubble(
                      message: data['message'],
                      isCurrentUser: isCurrentUser,
                      id: data['id'],
                      chatroomID: data['chatroomID'],
                      read: data['read'],
                      onDelete: () => deleteMessage(
                        data['chatroomID'],
                        data['id'],
                      ),
                    ),
        ],
      ),
    );
  }

  // build message input
  Widget _buildUserInput() {
    return Container(
      color: const Color.fromARGB(10, 110, 46, 26),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
        child: Row(
          children: [
            // picture icon
            IconButton(
              onPressed: () {
                log('choose picture');
                sendImage();
              },
              icon: const Icon(Icons.image_outlined),
              color: Colors.green,
              iconSize: 30,
            ),

            // video icon
            IconButton(
              onPressed: () {
                log('choose video');
                sendVideo();
              },
              icon: const Icon(Icons.video_camera_front_outlined),
              color: Colors.green,
              iconSize: 30,
            ),

            // textfield
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 5, right: 5),
                child: MyTextField(
                  controller: _messageController,
                  hintText: 'Type a message',
                  obscureText: false,
                  focusNode: myFocusNode,
                ),
              ),
            ),

            // send button
            Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(right: 10, left: 5),
              child: IconButton(
                onPressed: sendMessage,
                icon: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
