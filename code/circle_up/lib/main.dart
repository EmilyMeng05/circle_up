import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/auth_modal.dart';
import 'package:circle_up/auth/auth_provider.dart';
import 'views/sign_up.dart';
import 'views/no_group_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Circle Up',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => AuthModal(),
          '/signUp': (context) => SignUp(),
          '/noGroup': (context) => const NoGroupPage(),
        },
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return FutureBuilder<bool>(
              future: authProvider.isAuthenticated,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return snapshot.data == true ? const NoGroupPage() : AuthModal();
              },
            );
          },
        ),
      ),
    );
  }
}