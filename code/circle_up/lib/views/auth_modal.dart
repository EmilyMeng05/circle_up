// This will be the authentication modal that will be used to either sign in OR sign up a user

import 'package:flutter/material.dart';
import 'package:circle_up/components/text_field.dart';
import 'package:circle_up/components/enter_button.dart';
import 'package:circle_up/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:circle_up/services/alarm_circle_service.dart';
import 'package:circle_up/views/circle_page.dart';

/*
 * Represents the Login modal for the circle up application as a StatelessWidget
 * If the user enters this modal, they will be prompted to login to the application
 * If the user is not signed up to the application, they can navigate to the sign up page
*/
class AuthModal extends StatelessWidget {
  AuthModal({super.key});
  final TextEditingController emailController = TextEditingController(); // Controller for the email input
  final TextEditingController passwordController = TextEditingController(); // Controller for the password input

  // Handle sign in errors and display appropriate messages to the user
  // If the user is authenticated and in a group, navigate to their Circle page
  // If the user is authenticated but not in a group, navigate to the no group page
  // In all other cases, do nothing, since the user is not authenticated
  // If an error occurs during the sign-in process, an error message will be displayed
  Future<void> _handleLogin(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signIn(emailController.text, passwordController.text);

    // Ensures the user is authenticated
    if (authProvider.isAuthenticated) {
      // Checks if the user is already in a group
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
          // The user is not in a group
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/noGroup');
          }
        }
      } else {
        // The user is authenticated but not in a group
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/noGroup');
        }
      }
    }
  }

  /*
   * Builds the login modal UI
   * This allows the user to enter their email and password and login
   * It also allows the user to navigate to the sign up page if they do not have an account
  */
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
                  'Welcome back to Circle Up! 👋',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s get you back to your morning routine',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
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
                      await _handleLogin(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: $e')),
                        );
                      }
                    }
                  },
                  text: 'Login',
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signUp');
                  },
                  child: Text(
                    'Don\'t have an account? Sign Up',
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
