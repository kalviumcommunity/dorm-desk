import 'package:flutter/material.dart';
import '../widgets/info_card.dart';
import '../widgets/like_button.dart';
import '../widgets/service_request_card.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  int _totalLikes = 0;

  void _onLikeChanged(int likes) {
    setState(() {
      _totalLikes = likes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dormitory Services'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Like Button
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Service Center',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                LikeButton(
                  initialLikes: 42,
                  onLikeChanged: _onLikeChanged,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Service Categories using InfoCard
            Text(
              'Service Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Maintenance',
              subtitle: 'Room repairs and fixtures',
              icon: Icons.build,
              iconColor: Colors.blue,
              onTap: () => _showCategoryDetails('Maintenance'),
            ),
            InfoCard(
              title: 'Housekeeping',
              subtitle: 'Cleaning and sanitation',
              icon: Icons.cleaning_services,
              iconColor: Colors.green,
              onTap: () => _showCategoryDetails('Housekeeping'),
            ),
            InfoCard(
              title: 'Security',
              subtitle: 'Safety and access control',
              icon: Icons.security,
              iconColor: Colors.red,
              onTap: () => _showCategoryDetails('Security'),
            ),
            const SizedBox(height: 24),

            // Recent Requests using ServiceRequestCard
            Text(
              'Recent Requests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ServiceRequestCard(
              title: 'Broken Window',
              description: 'Window pane cracked in Room 302',
              priority: 'High',
              icon: Icons.window,
              status: 'Pending',
              likes: 5,
              onTap: () => _showRequestDetails('Broken Window'),
            ),
            ServiceRequestCard(
              title: 'WiFi Issues',
              description: 'No internet connection in West Wing',
              priority: 'Medium',
              icon: Icons.wifi,
              status: 'In Progress',
              likes: 12,
              onTap: () => _showRequestDetails('WiFi Issues'),
            ),
            ServiceRequestCard(
              title: 'Water Supply',
              description: 'Low water pressure in 2nd floor',
              priority: 'Low',
              icon: Icons.water_drop,
              status: 'Completed',
              likes: 3,
              onTap: () => _showRequestDetails('Water Supply'),
            ),
            const SizedBox(height: 24),

            // Stats Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Statistics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem('Total Likes', '$_totalLikes'),
                      ),
                      Expanded(
                        child: _buildStatItem('Pending', '8'),
                      ),
                      Expanded(
                        child: _buildStatItem('Completed', '15'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  void _showCategoryDetails(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$category Services'),
        content: Text('Browse all $category related services and submit requests.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening $category services...')),
              );
            },
            child: const Text('Browse'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(String request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request ID: #${DateTime.now().millisecondsSinceEpoch}'),
            const SizedBox(height: 8),
            Text('Status: Being processed'),
            const SizedBox(height: 8),
            Text('Estimated completion: 2-3 hours'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request details updated!')),
              );
            },
            child: const Text('Track'),
          ),
        ],
      ),
    );
  }
}
