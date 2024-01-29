import 'dart:developer';

import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final String messageID;
  final String chatroomID;
  final Function onDelete;
  final Function(String editedMessage) onChange;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageID,
    required this.chatroomID,
    required this.onDelete,
    required this.onChange,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  // message controller
  late TextEditingController _editingController;

  late String _editedMessage;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _editedMessage = widget.message;
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  // delete a message
  void deleteOrEditMessage() {
    // show dialog box asking for confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // cancel button
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 25,
                  onPressed: () => Navigator.pop(context),
                ),
                // edit button
                IconButton(
                  icon: const Icon(Icons.edit),
                  iconSize: 25,
                  onPressed: () {
                    log('edit message');
                    Navigator.pop(context);
                    startEditing();
                  },
                ),
                // delete button
                IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: 25,
                  onPressed: () async {
                    // invoke onDelete function
                    widget.onDelete();
                    // dismiss the dialog
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // start editing message process
  void startEditing() {
    log('in startEditing');
    _editingController.text = _editedMessage;
    log('message: ${_editingController.text}');

    // show a dialog with a text input for editing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: _editingController,
          onChanged: (editedText) {
            setState(() {
              _editedMessage = editedText;
            });
          },
        ),
        actions: [
          // save button
          TextButton(
            onPressed: () async {
              // invoke onChange function
              widget.onChange(_editedMessage);
              // dismiss the dialog
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.isCurrentUser
              ? const Color.fromARGB(255, 128, 223, 131)
              : const Color.fromARGB(166, 165, 158, 189),
          borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: IntrinsicWidth(
        child: GestureDetector(
          onLongPress: widget.isCurrentUser ? deleteOrEditMessage : () {},
          child: Row(
            children: [
              Text(
                widget.message,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
