import 'package:flutter/material.dart';

class WidgetTreeDemo extends StatefulWidget {
  const WidgetTreeDemo({super.key});

  @override
  State<WidgetTreeDemo> createState() => _WidgetTreeDemoState();
}

class _WidgetTreeDemoState extends State<WidgetTreeDemo> {
  int count = 0;
  Color bg = Colors.white;

  void updateState() {
    setState(() {
      count++;
      bg = count % 2 == 0 ? Colors.white : Colors.blue.shade50;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text("Widget Tree Demo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_tree, size: 60),
            const SizedBox(height: 16),
            Text(
              "Count: $count",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: updateState,
              child: const Text("Update State"),
            ),
          ],
        ),
      ),
    );
  }
}