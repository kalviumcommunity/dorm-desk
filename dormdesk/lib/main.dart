import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/auth_gate.dart';
import 'screens/signup_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/scrollable_views.dart';
import 'screens/responsive_design_demo.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DormDeskApp());

}

class DormDeskApp extends StatelessWidget {

  const DormDeskApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      title: "DormDesk",

      debugShowCheckedModeBanner: false,

      home: const AuthGate(),

      routes: {

        '/signup': (context) => SignupScreen(),

        '/responsive': (context) => const ResponsiveLayout(),

        '/scrollable': (context) => const ScrollableViews(),

        '/responsive-design': (context) => const ResponsiveDesignDemo(),

      },

    );

  }

}