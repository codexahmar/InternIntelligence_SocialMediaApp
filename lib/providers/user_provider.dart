import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();

  UserModel? get user => _user;

  Future<void> initializeUser() async {
    UserModel? user = await _authService.getUserDetails();
    _user = user;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    UserModel? user = await _authService.getUserDetails();
    _user = user;
    notifyListeners();
  }

  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
