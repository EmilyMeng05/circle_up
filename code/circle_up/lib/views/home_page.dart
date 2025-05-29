import 'package:circle_up/components/enter_button.dart';
import 'package:flutter/material.dart';
import 'package:circle_up/auth/auth_provider.dart';
import 'package:circle_up/views/upload_photos.dart';
import 'package:circle_up/auth/auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.alarm, size: 100, color: Colors.black),
            const SizedBox(height: 20),
            const Text('Welcome to Circle Up!'),
            const SizedBox(height: 20),
            EnterButton(
              onTap: () async {
                // Navigate to the sign-up page
                final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
                bool authValid = await authProvider.isAuthenticated;
                if (authValid) {
                  Navigator.pushNamed(context, '/photos');
                } else {
                  Navigator.pushNamed(context, '/signUp');
                }
              },
              text: 'Get Started',
            ),
          ],
        ),
      ),
    );
  }
}
