import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'issues_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int issuesRaisedToday = 0;
  bool isExpanded = false;
  bool showMessage = false;

  late AnimationController _rotationController;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void raiseIssue() {
    setState(() {
      issuesRaisedToday++;
      isExpanded = !isExpanded;
      showMessage = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showMessage = false;
        });
      }
    });
  }

  void goToDetails() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) => const IssueDetailsScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DormDesk Dashboard'),
        actions: [
          RotationTransition(
            turns: _rotationController,
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.refresh),
            ),
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
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: double.infinity,
              height: isExpanded ? 180 : 120,
              decoration: BoxDecoration(
                color: isExpanded ? Colors.blueAccent : Colors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Issues Today: $issuesRaisedToday',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            AnimatedOpacity(
              opacity: showMessage ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: const Text(
                'Issue Raised Successfully!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: raiseIssue,
              child: const Text('Raise Issue'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: goToDetails,
              child: const Text('View Issue Details'),
            ),
          ],
        ),
      ),
    );
  }
}
