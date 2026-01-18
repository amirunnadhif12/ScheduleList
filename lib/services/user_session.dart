import 'package:flutter/material.dart';

class UserSession extends ChangeNotifier {
  static final UserSession _instance = UserSession._internal();
  
  factory UserSession() {
    return _instance;
  }
  
  UserSession._internal();

  int? _userId;
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;

  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;

  void login({
    required int userId,
    required String userName,
    required String userEmail,
  }) {
    _userId = userId;
    _userName = userName;
    _userEmail = userEmail;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _userName = null;
    _userEmail = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void updateUserName(String name) {
    _userName = name;
    notifyListeners();
  }
}
