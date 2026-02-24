import 'package:flutter/material.dart';
import 'screens/location_maps_demo.dart';

void main() {
  runApp(const LocationDemoApp());
}

class LocationDemoApp extends StatelessWidget {
  const LocationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location & Maps Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3), // Blue color
          brightness: Brightness.light,
        ),
      ),
      home: const LocationMapsDemo(),
    );
  }
}
