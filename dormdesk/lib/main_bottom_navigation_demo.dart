import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/bottom_navigation_minimal.dart';

void main() {
  runApp(const BottomNavigationApp());
}

class BottomNavigationApp extends StatelessWidget {
  const BottomNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4), // Purple color for navigation
          brightness: Brightness.light,
        ),
      ),
      home: const BottomNavigationMinimal(),
    );
  }
}
