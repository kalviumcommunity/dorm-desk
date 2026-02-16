import 'package:flutter/material.dart';

/// ------------------------------
/// Stateless Widget
/// ------------------------------
class DemoHeader extends StatelessWidget {
  const DemoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Interactive Counter App',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// ------------------------------
/// Stateful Widget
/// ------------------------------
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;

  void incrementCounter() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Count: $count',
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: incrementCounter,
          child: const Text('Increase'),
        ),
      ],
    );
  }
}

/// ------------------------------
/// Main Demo Screen
/// ------------------------------
class StatelessStatefulDemo extends StatelessWidget {
  const StatelessStatefulDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateless vs Stateful'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            DemoHeader(),          // Stateless Widget
            SizedBox(height: 30),
            CounterWidget(),       // Stateful Widget
          ],
        ),
      ),
    );
  }
}
