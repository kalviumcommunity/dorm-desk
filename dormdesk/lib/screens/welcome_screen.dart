import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isWelcome = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DormDesk'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apartment,
              size: 80,
              color: isWelcome ? Colors.blue : Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              isWelcome
                  ? 'Welcome to DormDesk'
                  : 'Let’s Manage Hostel Issues!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isWelcome ? Colors.black : Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isWelcome = !isWelcome;
                });
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
