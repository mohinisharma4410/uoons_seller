import 'package:flutter/material.dart';
import 'package:uoons/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightmode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightmode) {
      themeData = darkmode;
    } else {
      themeData = lightmode;
    }
  }
}

class LoginFormState extends ChangeNotifier {
  bool isPhoneLogin = true;

  void toggleLoginForm() {
    isPhoneLogin = !isPhoneLogin;
    notifyListeners();
  }
}
