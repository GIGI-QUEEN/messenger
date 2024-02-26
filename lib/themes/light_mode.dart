import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade300,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
  ),
);

const mainBlack = Color.fromRGBO(54, 53, 51, 1);

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    background: mainBlack,
    primary: Colors.grey.shade500,
    secondary: mainBlack,
/*     primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900, */
  ),
  //textTheme: textTheme,
);

/* TextTheme textTheme = TextTheme(
  bodyText1: TextStyle(color: Colors.black),
);
 */