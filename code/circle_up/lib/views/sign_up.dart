// This will have the sign-up logic for the application
import 'package:flutter/material.dart';
import 'package:circle_up/components/text_field.dart';
import 'package:circle_up/components/enter_button.dart';
import '../auth/auth_provider.dart';
import '../auth/auth.dart';


class SignUp extends StatelessWidget {
  SignUp({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                onTap: () async {
                  await AuthProvider().signUp(
                    emailController.text,
                    passwordController.text,
                  );
                },
                text: 'Sign Up',
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Navigate to the sign-up page
                  Navigator.pushNamed(context, '/login');
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
