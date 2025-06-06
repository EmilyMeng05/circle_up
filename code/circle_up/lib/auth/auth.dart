import 'package:firebase_auth/firebase_auth.dart';

/// This class will handle basic Firebase Authentication logic like 
/// sign in ,sign up, sign out
class Auth {
  // Sign-in function that authenticates a user with the given email and password
  Future<void> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      /// check for issues when login fails 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        rethrow;
      } else if (e.code == 'wrong-password') { 
        rethrow;
      }
    }
  }

  // Sign-up function that creates a new user, with the provided email and password
  Future<void> signUp(String email, String password) async {
    // Implement sign-up logic here
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        //print('The password provided is too weak.');
        rethrow;
      } else if (e.code == 'email-already-in-use') {
        //print('The account already exists for that email.');
        rethrow;
      }
    } catch (e) {
      //print(e);
    }
  }
  
  /// Signs out the current user
  Future<void> signOut() async {
    // Implement sign-out logic here
    await FirebaseAuth.instance.signOut();
  }

  /// This function will check if the user is authenticated or not
  /// Return: 
  /// - true if a user is logged in, false otherwise
  Future<bool> isAuthenticated() async {
    return FirebaseAuth.instance.currentUser != null;
  }
}
