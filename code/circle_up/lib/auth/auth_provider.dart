import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth.dart';
import '../models/user.dart'; // Import your custom AppUser model
import '../services/user_service.dart'; // Handles Firestore user info

/// This class handles the full authentication and user state of the current app user.
class AuthProvider extends ChangeNotifier {
  final Auth _auth = Auth(); // Handles FirebaseAuth operations (signIn, signUp, etc.)
  final UserService _userService = UserService(); // Handles Firestore user document

  bool _isAuthenticated = false; // True if user is signed in
  bool _isInGroup = false; // True if user belongs to a circle group
  AppUser? _user; // Our custom user model (AppUser) loaded from Firestore

  /// Getters to access state
  bool get isAuthenticated => _isAuthenticated;
  bool get isInGroup => _isInGroup;
  AppUser? get user => _user; // This is the one you'll use to get displayName, photoUrl, etc.
  User? get firebaseUser => FirebaseAuth.instance.currentUser; // Raw Firebase user object

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signIn(email, password); // Sign in with Firebase Auth
      //print("user signed in");
      _isAuthenticated = true;
      await FirebaseAuth.instance.currentUser?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser?.displayName == null || refreshedUser!.displayName!.isEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshedUser?.uid)
            .get();
        final firestoreName = doc.data()?['displayName'];
        if (firestoreName != null) {
          await refreshedUser?.updateDisplayName(firestoreName);
        }
      }
      await _userService.createOrUpdateUser();
      _user = await _userService.getUser();
      _isInGroup = await _userService.isUserInGroup();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }


  /// Signs up a new user and creates a corresponding Firestore user document
  Future<void> signUp(String email, String password, String username) async {
    try {
      await _auth.signUp(email, password); // FirebaseAuth
      // Set FirebaseAuth's displayName directly
      await FirebaseAuth.instance.currentUser?.updateDisplayName(username);
      _isAuthenticated = true;
      // Now store the user in Firestore, including displayName
      await _userService.createOrUpdateUser();
      // Load updated user from Firestore
      _user = await _userService.getUser();
      _isInGroup = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Signs the user out of the app
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _isAuthenticated = false;
      _isInGroup = false;
      _user = null; // Clear local user state
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Called on app launch or auth state change to verify if the user is logged in
  Future<void> checkAuthState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      _isAuthenticated = user != null;
      if (_isAuthenticated) {
        // Load user's full AppUser data and group status
        _user = await _userService.getUser();
        _isInGroup = await _userService.isUserInGroup();
      } else {
        _user = null;
        _isInGroup = false;
      }

      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _isInGroup = false;
      _user = null;
      notifyListeners();
    }
  }

  /// Reloads the AppUser data from Firestore
  /// Useful when updating displayName, profile pic, etc.
  Future<void> refreshUser() async {
    _user = await _userService.getUser();
    notifyListeners();
  }
}