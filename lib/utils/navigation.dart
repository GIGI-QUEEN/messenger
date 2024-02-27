import 'package:flutter/material.dart';
import 'package:secure_messenger/pages/profile_page/profile_page.dart';

void navigateTo(BuildContext context, MaterialPageRoute route) {
  Navigator.push(context, route);
}

void navigateToNamed(BuildContext context, String pathName) {
  Navigator.pushNamed(context, pathName);
}

void navigatoToProfilePage(BuildContext context, String userId) {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)));
}
