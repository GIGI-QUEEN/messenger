import 'package:flutter/material.dart';

/* class UserAvatar extends StatelessWidget {
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
} */

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.radius,
    this.iconColor,
    this.iconSize,
    this.iconBorderColor,
  });
  final String? imageUrl;
  final double? radius;
  final Color? iconColor;
  final double? iconSize;
  final Color? iconBorderColor;
  @override
  Widget build(BuildContext context) {
    return imageUrl != null
        ? CircleAvatar(
            backgroundImage: NetworkImage(imageUrl!),
            radius: radius,
          )
        : Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: iconBorderColor ?? Colors.black),
            ),
            child: Icon(
              Icons.person,
              color: iconColor ?? Colors.black,
              size: iconSize ?? 35,
            ),
          );
  }
}
