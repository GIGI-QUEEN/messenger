import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.radius,
    this.iconColor,
    this.iconSize,
  });
  final String? imageUrl;
  final double? radius;
  final Color? iconColor;
  final double? iconSize;
  @override
  Widget build(BuildContext context) {
    return imageUrl != null
        ? CircleAvatar(
            backgroundImage: NetworkImage(imageUrl!),
            radius: radius,
          )
        : Icon(
            Icons.person,
            color: iconColor ?? Colors.black,
            size: iconSize,
          );
  }
}
