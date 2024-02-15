import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String imageURL;
  final Widget? subtitle;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.text,
    required this.imageURL,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 25,
        ),
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          // image
          (imageURL != '')
              ? CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(imageURL),
                )
              : const Icon(
                  Icons.person,
                ),
          // Image.network(imageURL),
          //const Icon(Icons.person),
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                subtitle!,
              ],
            ],
          ),
        ]),
      ),
    );
  }
}
