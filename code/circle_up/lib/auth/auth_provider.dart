

import 'package:flutter/material.dart';
import '../auth/auth.dart';
class AuthProvider extends ChangeNotifier {
  // This class will handle the authentication state of the current user

  final Auth _auth = Auth(); // Instance of the Auth class to handle auth logic
  bool _isAuthenticated = false;


  Future<void> signIn(String email, String password) async {
    await _auth.signIn(email, password);
    _isAuthenticated = await _auth.isAuthenticated();
    // print("User Authenticated!");
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    await _auth.signUp(email, password);
    _isAuthenticated = await _auth.isAuthenticated();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _isAuthenticated = await _auth.isAuthenticated();
    notifyListeners();
  }
  
  bool get isAuthenticated => _isAuthenticated; // Gets to check if the user is authenticated
}