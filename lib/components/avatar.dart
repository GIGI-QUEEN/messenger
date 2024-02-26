import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.imageUrl});
  final String? imageUrl;
  @override
  Widget build(BuildContext context) {
    return imageUrl != null
        ? CircleAvatar(
            backgroundImage: NetworkImage(imageUrl!),
          )
        : const Icon(
            Icons.person,
            color: Colors.black,
          );
  }
}
