// This will have the sign-up logic for the application
import 'package:flutter/material.dart';
import 'package:circle_up/components/text_field.dart';
import 'package:circle_up/components/enter_button.dart';
import '../auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:circle_up/services/alarm_circle_service.dart';
import 'package:circle_up/views/circle_page.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _handleSignUp(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signUp(
      emailController.text,
      passwordController.text,
    );

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
              SizedBox(height: 50),
              Icon(Icons.alarm, size: 100, color: Colors.black),
              SizedBox(height: 20),
              Text('Welcome to Circle Up, Please Sign Up!'),
              SizedBox(height: 20),
              CustomTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              SizedBox(height: 20),
              EnterButton(
                onTap: () => _handleSignUp(context),
                text: 'Sign Up',
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Already have an account? Sign In',
                  style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
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
