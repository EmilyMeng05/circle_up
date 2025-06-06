// This will be the authentication modal that will be used to either sign in OR sign up a user

import 'package:flutter/material.dart';
import 'package:circle_up/components/text_field.dart';
import 'package:circle_up/components/enter_button.dart';
import 'package:circle_up/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:circle_up/services/alarm_circle_service.dart';
import 'package:circle_up/views/circle_page.dart';

class AuthModal extends StatelessWidget {
  AuthModal({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _handleLogin(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signIn(emailController.text, passwordController.text);

    if (authProvider.isAuthenticated) {
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
