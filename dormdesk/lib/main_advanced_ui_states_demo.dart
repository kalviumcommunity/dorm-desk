import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/advanced_ui_states_demo.dart';

void main() {
  runApp(const AdvancedUIStatesApp());
}

class AdvancedUIStatesApp extends StatelessWidget {
  const AdvancedUIStatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced UI States Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4), // Purple color for advanced states
          brightness: Brightness.light,
        ),
      ),
      home: const AdvancedUIStatesDemo(),
    );
  }
}
