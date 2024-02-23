import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

class ImageMessageTile extends StatelessWidget {
  const ImageMessageTile({
    super.key,
    required this.message,
  });
  final ImageMessage message;
  @override
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image(
          width: 200,
          height: 250,
          image: NetworkImage(message.uri),
        ));
  }
}
