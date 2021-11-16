import 'package:flutter/material.dart';
import 'dart:io';

class LoginStatus with ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _loggedIn = false;
  String _userID = '';
  String _userAvatarUrl = '';
  late File currentImg;

  set userAvatarUrl(String value) {
    _userAvatarUrl = value;
  }

  String get userAvatarUrl => _userAvatarUrl;

  ///****************************************************************************************///

  set userID(String value) {
    _userID = value;
  }

  ///****************************************************************************************///

  String get userID => _userID;

  ///****************************************************************************************///

  set loggedIn(bool value) {
    _loggedIn = value;
    notifyListeners();
  }

  ///****************************************************************************************///

  bool get loggedIn => _loggedIn;

  ///****************************************************************************************///

  String get email => _email;

  ///****************************************************************************************///

  String get password => _password;

  ///****************************************************************************************///

  set email(String value) {
    _email = value;
  }

  ///****************************************************************************************///

  set password(String value) {
    _password = value;
  }
}

///****************************************************************************************///
