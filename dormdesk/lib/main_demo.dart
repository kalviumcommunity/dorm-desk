import 'package:flutter/material.dart';
import 'screens/hot_reload_demo.dart';

void main() {
  runApp(const HotReloadDemoApp());
}

class HotReloadDemoApp extends StatelessWidget {
  const HotReloadDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hot Reload Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      home: const HotReloadDemo(),
    );
  }
}
