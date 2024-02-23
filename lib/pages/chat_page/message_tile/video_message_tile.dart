import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:video_player/video_player.dart';

class VideoMessageTile extends StatefulWidget {
  const VideoMessageTile({super.key, required this.message});
  final VideoMessage message;

  @override
  State<VideoMessageTile> createState() => _VideoMessageTileState();
}

class _VideoMessageTileState extends State<VideoMessageTile> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.message.uri))
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
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 15),
      //height: 150,
      width: 200,
      height: 150,
      child: Chewie(controller: _chewieController),
    );
  }
}
