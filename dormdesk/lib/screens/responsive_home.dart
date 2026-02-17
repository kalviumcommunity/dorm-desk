import 'package:flutter/material.dart';
import 'user_input_form.dart';

class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("DormDesk Responsive"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserInputForm()),
              );
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: isWide ? _tabletLayout() : _phoneLayout(),
    );
  }

  Widget _phoneLayout() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _cards(),
    );
  }

  Widget _tabletLayout() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: _cards(),
    );
  }

  List<Widget> _cards() {
    final items = [
      "Plumbing",
      "Electrical",
      "Mess",
      "Cleaning",
      "Water",
      "Furniture"
    ];

    return items.map((e) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.build, size: 40),
              const SizedBox(height: 10),
              Text(e, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }).toList();
  }
}