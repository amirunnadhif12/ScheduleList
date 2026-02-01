import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Load session dari SharedPreferences saat app dimulai
  Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (_isLoggedIn) {
      _userId = prefs.getInt('userId');
      _userName = prefs.getString('userName');
      _userEmail = prefs.getString('userEmail');
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> login({
    required int userId,
    required String userName,
    required String userEmail,
  }) async {
    _userId = userId;
    _userName = userName;
    _userEmail = userEmail;
    _isLoggedIn = true;
    
    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', userId);
    await prefs.setString('userName', userName);
    await prefs.setString('userEmail', userEmail);
    
    notifyListeners();
  }

  Future<void> logout() async {
    _userId = null;
    _userName = null;
    _userEmail = null;
    _isLoggedIn = false;
    
    // Hapus dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    
    notifyListeners();
  }

  void updateUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    notifyListeners();
  }
}
