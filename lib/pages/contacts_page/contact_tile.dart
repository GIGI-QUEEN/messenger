import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:secure_messenger/components/avatar.dart';
import 'package:secure_messenger/utils/date_formatting.dart';

class UserTile extends StatelessWidget {
  UserTile({super.key, required this.user, this.onTap});
  final User user;
  final Function()? onTap;
  final DateFormatting _dateFormatting = DateFormatting();
  @override
  Widget build(BuildContext context) {
    final lastSeen = _dateFormatting.formatDateTime(user.lastSeen!);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 245, 245, 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          user.metadata!['username'],
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          'last seen: $lastSeen',
          style: const TextStyle(color: Color.fromARGB(255, 121, 121, 121)),
        ),
        leading: UserAvatar(
          imageUrl: user.imageUrl,
        ),
      ),
    );
  }
}
