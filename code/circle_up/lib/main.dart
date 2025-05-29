import 'package:circle_up/views/upload_photos.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'views/auth_modal.dart';
import 'package:circle_up/auth/auth_provider.dart';
import 'views/sign_up.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'views/home_page.dart';
void main() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(), 
      child: const MyApp(),
    ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => AuthModal(),
        '/signUp': (context) => SignUp(),
        '/photos': (context) => UploadPhotos(),
      },
      initialRoute: '/home',
    );
  }
}