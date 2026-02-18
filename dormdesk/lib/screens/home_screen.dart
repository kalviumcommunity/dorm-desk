import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int issuesRaisedToday = 0;
  bool isDarkMode = false;
  bool isAcknowledged = false;

  final AuthService _authService = AuthService();

  void raiseIssue() {
    setState(() {
      issuesRaisedToday++;
    });
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void toggleAcknowledgement() {
    setState(() {
      isAcknowledged = !isAcknowledged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('DormDesk Dashboard'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Issues Raised Today',
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              issuesRaisedToday.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.greenAccent : Colors.blue,
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: raiseIssue,
              child: const Text('Raise New Issue'),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isAcknowledged ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isAcknowledged ? Colors.green : Colors.grey,
                  ),
                  onPressed: toggleAcknowledgement,
                ),
                Text(
                  isAcknowledged
                      ? 'Issue Acknowledged'
                      : 'Acknowledge Issue',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            Text(
              isDarkMode ? 'Dark Mode Enabled' : 'Light Mode Enabled',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
