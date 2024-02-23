import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

class TextMessageTile extends StatelessWidget {
  const TextMessageTile({
    super.key,
    required this.message,
    required this.borderRadius,
    required this.bgColor,
  });
  final TextMessage message;
  final BorderRadius borderRadius;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      constraints:
          const BoxConstraints(minWidth: 50, minHeight: 30, maxWidth: 170),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: bgColor,
      ),
      child: Text(
        message.text,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
