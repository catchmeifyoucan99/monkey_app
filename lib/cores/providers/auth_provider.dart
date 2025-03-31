import 'package:expense_personal/cores/model/user_model.dart';
import 'package:expense_personal/cores/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();

  UserModel? get user => _user;

  Future<bool> register(String email, String name, String password) async {
    _user = await _authService.register(email, name, password);
    notifyListeners();
    return _user != null;
  }

  Future<bool> login(String email, String password) async {
    _user = await _authService.login(email, password);
    notifyListeners();
    return _user != null;
  }


  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
