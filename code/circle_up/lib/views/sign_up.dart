import 'package:flutter/material.dart';
import 'package:circle_up/components/text_field.dart';
import 'package:circle_up/components/enter_button.dart';
import '../auth/auth_provider.dart' as local_auth;
import 'package:provider/provider.dart';
import 'package:circle_up/services/alarm_circle_service.dart';
import 'package:circle_up/views/circle_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// This class will have the sign-up logic for the application
/// including collecting user's email, password, and displayname
class SignUp extends StatelessWidget {
  SignUp({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // collect user name
  final TextEditingController usernameController = TextEditingController();

  // Handles the sign-up logic
  Future<void> _handleSignUp(BuildContext context) async {
    final authProvider = context.read<local_auth.AuthProvider>();
    await authProvider.signUp(
      emailController.text,
      passwordController.text,
      usernameController.text,
    );
    // after the user sign up, we ask their username and then store it in displayName
    if (authProvider.isAuthenticated) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'displayName': usernameController.text,
        });
      }
      //update the user
      await authProvider.refreshUser();
      // Check if user is in a group and redirect accordingly
      if (authProvider.isInGroup) {
        // Get the user's circle and navigate to CirclePage
        final circles = await AlarmCircleService().getUserCircles().first;
        if (circles.isNotEmpty) {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CirclePage(circle: circles.first),
              ),
            );
          }
        } else {
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/noGroup');
          }
        }
      } else {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/noGroup');
        }
      }
    }
  }

  ///The build method to build the widget
  ///this ui contains dields for display name, email, and password
  ///will also give user a sign up button, and a link to the login page
  ///Returns:
  ///- a scaffod object that builds the view described as above
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Icon(
                  Icons.alarm,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Join Circle Up! 🌅',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your morning routine journey with friends',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: usernameController,
                  hintText: 'Display Name',
                  obscureText: false,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                EnterButton(
                  onTap: () async {
                    try {
                      await _handleSignUp(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error signing up: $e')),
                        );
                      }
                    }
                  },
                  text: 'Sign Up',
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    'Already have an account? Log In',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}