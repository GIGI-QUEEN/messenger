import 'package:flutter/material.dart';

class ImageBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final String id;
  final String chatroomID;
  final bool read;
  final Function onDelete;

  const ImageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.id,
    required this.chatroomID,
    required this.read,
    required this.onDelete,
  });

  @override
  State<ImageBubble> createState() => _ImageBubbleState();
}

class _ImageBubbleState extends State<ImageBubble> {
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
          color: widget.isCurrentUser
              ? const Color.fromARGB(255, 128, 223, 131)
              : const Color.fromARGB(166, 165, 158, 189),
          borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: IntrinsicWidth(
        child: GestureDetector(
          onLongPress: widget.isCurrentUser ? deleteMessage : () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 200,
                width: 200,
                child: Image.network(widget.message),
              ),
              const SizedBox(width: 5),
              if (widget
                  .isCurrentUser) //  show ticks for current user's messages

                Icon(
                  widget.read
                      ? Icons.done_all //  green ticks if message is read
                      : Icons.done_all, // grey ticks if not read
                  color: widget.read ? Colors.blue : Colors.grey,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
