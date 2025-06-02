import 'package:flutter/material.dart';
import 'package:circle_up/components/text_field.dart';
import 'package:circle_up/components/enter_button.dart';
import 'package:circle_up/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class NoGroupPage extends StatelessWidget {
  const NoGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Circle Up',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Create New Circle Section
              const Text(
                'Create New Circle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              EnterButton(
                onTap: () {
                  // TODO: Implement create circle logic
                  print('Creating new circle');
                },
                text: 'Create New Circle',
              ),
              const SizedBox(height: 40),

              // Join Circle Section
              const Text(
                'Join Existing Circle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Circle Code',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              EnterButton(
                onTap: () {
                  // TODO: Implement join circle logic
                  print('Joining circle');
                },
                text: 'Join Circle',
              ),
            ],
          ),
        ),
      ),
    );
  }
}