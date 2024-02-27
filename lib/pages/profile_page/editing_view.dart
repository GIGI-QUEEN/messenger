import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/components/avatar.dart';
import 'package:secure_messenger/pages/profile_page/profile_provider.dart';

class EditingView extends StatelessWidget {
  const EditingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(builder: (context, model, _) {
      return Center(
        child: Column(
          children: [
            UserAvatar(
              imageUrl: model.user.imageUrl,
              radius: 100,
              iconColor: Colors.white,
              iconSize: 150,
            ),
            /*  const SizedBox(
              height: 10,
            ), */
            TextButton(
                onPressed: () => model.pickImage(),
                child: const Text('Set new photo'))
          ],
        ),
      );
    });
  }
}
