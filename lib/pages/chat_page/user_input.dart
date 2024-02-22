import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/pages/chat_page/chat_provider.dart';

class UserInput extends StatelessWidget {
  UserInput({super.key});
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PickImageButton(),
          PickVideoButton(),
          InputBar(
              //textEditingController: _textEditingController,
              ),
          SendButton(
            message: _textEditingController.text,
          ),
        ],
      ),
    );
  }
}

class InputBar extends StatelessWidget {
  const InputBar({super.key});
  // final FirebaseChatCore _firebaseChatCore = FirebaseChatCore.instance;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 45,
        child: Consumer<ChatProvider>(
          builder: (context, model, child) {
            return TextField(
              controller: model.textEditingController,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(bottom: 3, left: 20),
                fillColor: green,
                filled: true,
                hintText: 'type message...',
                hintStyle:
                    const TextStyle(color: Color.fromARGB(193, 255, 255, 255)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                //suffixIcon: Container(width: 100, child: PickFile())
                // prefixIcon: PickFile(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PickFile extends StatelessWidget {
  const PickFile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PickImageButton(),
        PickVideoButton(),
      ],
    );
  }
}

class PickImageButton extends StatelessWidget {
  const PickImageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, model, child) {
        return IconButton(
          onPressed: () {
            model.pickImage();
          },
          icon: const Icon(
            Icons.image,
            color: Colors.white,
          ),
          style: IconButton.styleFrom(backgroundColor: green),
          color: Colors.white,
        );
      },
    );
  }
}

class PickVideoButton extends StatelessWidget {
  const PickVideoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, model, child) {
        return IconButton(
          onPressed: () {
            model.pickVideo();
          },
          splashRadius: 10,
          icon: const Icon(
            Icons.video_file,
            color: Colors.white,
          ),
          style: IconButton.styleFrom(backgroundColor: green),
          color: Colors.white,
        );
      },
    );
  }
}

/* class InputBar extends StatelessWidget {
  const InputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 40,
      decoration:
          BoxDecoration(color: green, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
              padding: EdgeInsets.only(left: 20),
              width: 250,
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'message',
                    border: InputBorder.none,
                    helperStyle: TextStyle(
                      color: Colors.white,
                    )),
              ))
        ],
      ),
    );
  }
} */

class SendButton extends StatelessWidget {
  SendButton({super.key, required this.message});
  final String message;
  final FirebaseChatCore _firebaseChatCore = FirebaseChatCore.instance;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, model, child) {
        return IconButton(
          onPressed: () {
            /*  if (model.image != null) {
              model.sendImageMessage();
            } */
            if (model.video != null) {
              model.sendVideoMessage();
            }
            /*   if (model.image != null) {
              model.sendImageMessage();
            } else if (model.video != null) {
              model.sendVideoMessage();
            } else {
              final text = PartialText(
                  text: model.textEditingController.text,
                  metadata: const {
                    'isSeen': false,
                  });
              _firebaseChatCore.sendMessage(text, model.roomId);
              model.textEditingController.clear();
            } */
            /*   if (model.partialImage != null) {
              _firebaseChatCore.sendMessage(model.partialImage, model.roomId);
            } else {
              final text = PartialText(
                  text: model.textEditingController.text,
                  metadata: const {
                    'isSeen': false,
                  });
              _firebaseChatCore.sendMessage(text, model.roomId);
              model.textEditingController.clear();
            } */
          },
          icon: const Icon(Icons.arrow_forward),
          style: IconButton.styleFrom(backgroundColor: green),
          color: Colors.white,
        );
      },
      /*   child: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.arrow_forward),
        style: IconButton.styleFrom(backgroundColor: green),
        color: Colors.white,
      ), */
    );
  }
}

const green = Color.fromRGBO(38, 192, 166, 1);

/* class SelectImageOrVideo extends StatelessWidget {
  const SelectImageOrVideo({super.key});
  final List<bool> _selectedChoice = <bool>[false, false];

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      child: ToggleButtons(children: [], isSelected: isSelected),
    );
  }
}
 */