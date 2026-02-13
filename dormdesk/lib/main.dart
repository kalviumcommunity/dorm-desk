import 'package:flutter/material.dart';
import 'screens/widget_tree_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DormDesk Widget Tree Demo',
      home: WidgetTreeDemo(),
    );
  }
}