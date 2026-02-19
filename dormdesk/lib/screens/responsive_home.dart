import 'package:flutter/material.dart';
import 'user_input_form.dart';
import 'services_screen.dart';
import 'asset_demo_screen.dart';
import '../widgets/info_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/service_request_card.dart';

class ResponsiveHome extends StatefulWidget {
  const ResponsiveHome({super.key});

  @override
  State<ResponsiveHome> createState() => _ResponsiveHomeState();
}

class _ResponsiveHomeState extends State<ResponsiveHome> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.svg',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 12),
            const Text("DormDesk Responsive"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssetDemoScreen()),
              );
            },
            tooltip: 'Assets Demo',
          ),
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
          IconButton(
            icon: const Icon(Icons.miscellaneous_services),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicesScreen()),
              );
            },
            tooltip: 'All Services',
          ),
        ],
      ),
      body: isWide ? _tabletLayout() : _phoneLayout(),
    );
  }

  Widget _phoneLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions Section
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                QuickActionButton(
                  label: 'Plumbing',
                  icon: Icons.plumbing,
                  onPressed: () => _showServiceDetails('Plumbing'),
                  width: 100,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  label: 'Electrical',
                  icon: Icons.electrical_services,
                  onPressed: () => _showServiceDetails('Electrical'),
                  width: 100,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  label: 'Cleaning',
                  icon: Icons.cleaning_services,
                  onPressed: () => _showServiceDetails('Cleaning'),
                  width: 100,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  label: 'Mess',
                  icon: Icons.restaurant,
                  onPressed: () => _showServiceDetails('Mess'),
                  width: 100,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Service Requests Section
          Text(
            'Recent Service Requests',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._serviceRequestCards(),
          
          const SizedBox(height: 24),
          
          // Info Cards Section
          Text(
            'Dormitory Services',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._infoCards(),
        ],
      ),
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

  void _showServiceDetails(String service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$service Service'),
        content: Text('Request $service maintenance for your dorm room.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$service request submitted!')),
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  List<Widget> _serviceRequestCards() {
    return [
      ServiceRequestCard(
        title: 'Leaky Faucet',
        description: 'Kitchen sink faucet is dripping continuously',
        priority: 'Medium',
        icon: Icons.plumbing,
        status: 'In Progress',
        likes: 3,
        onTap: () => _showServiceDetails('Plumbing'),
      ),
      ServiceRequestCard(
        title: 'Power Outage',
        description: 'Room 204 has no electricity since morning',
        priority: 'High',
        icon: Icons.electrical_services,
        status: 'Pending',
        likes: 7,
        onTap: () => _showServiceDetails('Electrical'),
      ),
      ServiceRequestCard(
        title: 'Room Cleaning',
        description: 'Request for deep cleaning of common areas',
        priority: 'Low',
        icon: Icons.cleaning_services,
        status: 'Completed',
        likes: 2,
        onTap: () => _showServiceDetails('Cleaning'),
      ),
    ];
  }

  List<Widget> _infoCards() {
    return [
      InfoCard(
        title: 'Room Maintenance',
        subtitle: 'Submit and track maintenance requests',
        icon: Icons.build,
        onTap: () => _showServiceDetails('Maintenance'),
      ),
      InfoCard(
        title: 'Dormitory Rules',
        subtitle: 'View guidelines and regulations',
        icon: Icons.gavel,
        onTap: () => _showServiceDetails('Rules'),
      ),
      InfoCard(
        title: 'Emergency Contacts',
        subtitle: 'Important numbers and contacts',
        icon: Icons.contact_phone,
        onTap: () => _showServiceDetails('Emergency'),
      ),
      InfoCard(
        title: 'Laundry Schedule',
        subtitle: 'Check washing machine availability',
        icon: Icons.local_laundry_service,
        onTap: () => _showServiceDetails('Laundry'),
      ),
    ];
  }
}