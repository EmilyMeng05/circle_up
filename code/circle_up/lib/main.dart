import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/auth_modal.dart';
import 'package:circle_up/auth/auth_provider.dart';
import 'views/sign_up.dart';
import 'views/no_group_page.dart';
import 'views/circle_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/alarm_circle_service.dart';

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
            return FutureBuilder<void>(
              future: authProvider.checkAuthState(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!authProvider.isAuthenticated) {
                  return AuthModal();
                }

                // If authenticated, check group status
                if (authProvider.isInGroup) {
                  // Get the user's circle and navigate to CirclePage
                  return FutureBuilder(
                    future: AlarmCircleService().getUserCircles().first,
                    builder: (context, circleSnapshot) {
                      if (circleSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!circleSnapshot.hasData || circleSnapshot.data!.isEmpty) {
                        return const NoGroupPage();
                      }

                      return CirclePage(circle: circleSnapshot.data!.first);
                    },
                  );
                }

                return const NoGroupPage();
              },
            );
          },
        ),
      ),
    );
  }
}