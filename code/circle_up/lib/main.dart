import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/auth_modal.dart';
import 'package:circle_up/auth/auth_provider.dart';
import 'views/sign_up.dart';
import 'views/no_group_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'views/upload_photos.dart';
import 'services/notification_service.dart';


/*
 * This represents the main entry point of the Circle Up Application
*/
void main() async {
  // Load the .env file in order to access any of the environment variables
  await dotenv.load(fileName: ".env");


  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the current platform's options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize the notification servicce
  // Request any notification permissions if required
  await NotificationService().initialize();
  await NotificationService().requestNotificationPermission();
  runApp(const MyApp());
}

/*
 * Represents the main widget to build the Circle Up Application
 * Sets up all of the routes, and defaults to the login page for the application
*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Circle Up',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            primary: const Color(0xFF6C63FF),
            secondary: const Color(0xFFFF6584),
            tertiary: const Color(0xFF4ECDC4),
            background: const Color(0xFFF7F7F7),
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F7F7),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3142),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
        initialRoute: '/login', // Default the route to the login page

        // Defines the routes for the application
        routes: {
          '/login': (context) => AuthModal(),
          '/signUp': (context) => SignUp(),
          '/noGroup': (context) => const NoGroupPage(),
          '/photo' : (context) => UploadPhotos(),
        },
      ),
    );
  }
}