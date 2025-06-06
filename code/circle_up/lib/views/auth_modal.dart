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
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Semantics(
                label: 'Alarm Icon',
                child: const Icon(Icons.alarm, size: 100, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: 'Welcome back to Circle Up, Please Log in',
                child: const Text('Welcome back to Circle Up, Please Log in'),
              ),
              const SizedBox(height: 20),
              // Input fields for the email
              Semantics(
                label: 'Email input field',
                textField: true,
                child: CustomTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
              ),
              const SizedBox(height: 10),
              // Input fields for the password
              Semantics(
                label: 'Password input field',
                textField: true,
                child: CustomTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 20),
              // Represents the login button
              // When the button is clicked, it will try to login the user
              // If there is an error, displays the error in a snackbar
              Semantics(
                label: 'Login button',
                button: true,
                child: EnterButton(
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
                ),
              ),
              const SizedBox(height: 20),
              // Using this gesture detector, the user can navigate to the sign up page if they do not have an account
              Semantics(
                label: 'Don\'t have an account? Sign Up link',
                button: true,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signUp');
                  },
                  child: const Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
