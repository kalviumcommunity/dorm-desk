import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/responsive_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const DormDeskApp());
}

class DormDeskApp extends StatelessWidget {
  const DormDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DormDesk',
      debugShowCheckedModeBanner: false,

      initialRoute: '/welcome',

      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/responsive': (context) => const ResponsiveLayout(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final uid = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(uid),
          );
        }
        return null;
      },
    );
  }
}