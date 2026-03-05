import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/ui_states_demo.dart';

void main() {
  runApp(const UIStatesApp());
}

class UIStatesApp extends StatelessWidget {
  const UIStatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI States Handling Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3), // Blue color for UI states
          brightness: Brightness.light,
        ),
      ),
      home: const UIStatesDemo(),
    );
  }
}
