import 'package:flutter/material.dart';
import 'package:secure_messenger/components/delete_button.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final String messageID;
  final String chatroomID;
  final Function onDelete;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageID,
    required this.chatroomID,
    required this.onDelete,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  // delete a message
  void deleteMessage() {
    // show dialog box asking for confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // delete button
          TextButton(
            onPressed: () async {
              // invoke onDelete function
              widget.onDelete();

              // dismiss the dialog
              Navigator.pop(context);
            },
            child: const Text('Delete for everyone'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.isCurrentUser ? Colors.green : Colors.grey.shade500,
          borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: IntrinsicWidth(
        child: GestureDetector(
          onLongPress: widget.isCurrentUser ? deleteMessage : () {},
          child: Row(
            children: [
              Text(
                widget.message,
                style: const TextStyle(color: Colors.white),
              ),

              /*  // delete button
              if (widget.isCurrentUser)
                DeleteButton(
                  context: context,
                  onTap: () => deleteMessage(),
                ), */
            ],
          ),
        ),
      ),
    );
  }
}
