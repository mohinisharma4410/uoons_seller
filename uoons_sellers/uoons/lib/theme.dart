import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.white,
    primary: Colors.orange.shade700,
    secondary: Colors.black,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black), // For primary text
    bodyMedium: TextStyle(color: Colors.black), // For secondary text
    bodySmall: TextStyle(color: Colors.grey), // For captions
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.orange.shade700,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  cardColor: Colors.white,
);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.black26,
    primary: Colors.orange.shade900,
    secondary: Colors.white,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white), // For primary text
    bodyMedium: TextStyle(color: Colors.white70), // For secondary text
    bodySmall: TextStyle(color: Colors.grey.shade400), // For captions
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.orange.shade900,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  cardColor: Colors.grey.shade900,
);
