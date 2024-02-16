import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final String id;
  final String chatroomID;
  final bool read;
  final Function onDelete;

  const VideoBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    required this.id,
    required this.chatroomID,
    required this.read,
    required this.onDelete,
  }) : super(key: key);

  @override
  _VideoBubbleState createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<VideoBubble> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.message))
          ..initialize().then((_) {
            setState(() {});
          });
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      showControls: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

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
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(7),
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onLongPress: widget.isCurrentUser ? deleteMessage : () {},
        child: _videoPlayerController.value.isInitialized
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    child: Chewie(
                      controller: _chewieController,
                    ),
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
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
