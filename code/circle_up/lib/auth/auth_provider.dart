import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  // This class will handle the authentication state of the current user

  final Auth _auth = Auth(); // Instance of the Auth class to handle auth logic
  final UserService _userService = UserService();
  bool _isAuthenticated = false;
  bool _isInGroup = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInGroup => _isInGroup;

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signIn(email, password);
      _isAuthenticated = true;
      // Create or update user document
      await _userService.createOrUpdateUser();
      // Check group status
      _isInGroup = await _userService.isUserInGroup();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.signUp(email, password);
      _isAuthenticated = true;
      // Create new user document
      await _userService.createOrUpdateUser();
      // New users start with no group
      _isInGroup = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _isAuthenticated = false;
      _isInGroup = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkAuthState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      _isAuthenticated = user != null;
      if (_isAuthenticated) {
        // Check group status for authenticated users
        _isInGroup = await _userService.isUserInGroup();
      }
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _isInGroup = false;
      notifyListeners();
    }
  }
}