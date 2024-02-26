import 'package:flutter/material.dart';

void navigateTo(BuildContext context, MaterialPageRoute route) {
  Navigator.push(context, route);
}

void navigateToNamed(BuildContext context, String pathName) {
  Navigator.pushNamed(context, pathName);
}
