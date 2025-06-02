import 'package:circle_up/components/enter_button.dart';
import 'package:flutter/material.dart';
import 'package:circle_up/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(icon: const Icon(Icons.question_mark),
            tooltip: 'Help',
            onPressed: () {
              // Display a dialog that explains what the app is.
              showDialog(
                context: context, 
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Welcome to Circle Up!'), 
                      content: const Text(
                        'Circle Up is an application that allows you to create and join groups (circles) with your friends and family.\n '
                        'You can customize an alarm time for your circle, and within 5 minutes of the alarm going off, submit a quick photo to ensure accountability!.\n\n'
                      )
                  );
                }
              );
            }
          )],
      ),
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
                  Navigator.pushNamed(context, '/signUp');
              },
              text: 'Get Started',
            ),
          ],
        ),
      ),
    );
  }
}
