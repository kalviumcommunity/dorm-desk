import 'package:flutter/material.dart';

class IssueDetailsScreen extends StatelessWidget {
  const IssueDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Details'),
      ),
      body: const Center(
        child: Text(
          'Detailed Issue Information',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
