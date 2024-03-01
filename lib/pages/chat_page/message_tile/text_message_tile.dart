import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/pages/chat_page/chat_provider.dart';

class TextMessageTile extends StatelessWidget {
  TextMessageTile({
    super.key,
    required this.message,
    required this.borderRadius,
    required this.bgColor,
  });
  final TextMessage message;
  final BorderRadius borderRadius;
  final Color bgColor;
  final FirebaseChatCore _firebaseChatCore = FirebaseChatCore.instance;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, model, _) {
        String textToShow = message.text;
        if (message.metadata!['isEncrypted'] == true) {
          textToShow = model.decryptMessageText(message);
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          constraints:
              const BoxConstraints(minWidth: 50, minHeight: 30, maxWidth: 170),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: bgColor,
          ),
          child: Text(
            textToShow,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
      },
    );
  }
}
