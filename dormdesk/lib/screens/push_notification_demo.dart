import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

/// Push Notification Demo Screen
/// 
/// Demonstrates Firebase Cloud Messaging (FCM) integration including:
/// - Permission management
/// - Token handling
/// - Topic subscriptions
/// - Message handling for different app states
/// - Notification history
class PushNotificationDemo extends StatefulWidget {
  const PushNotificationDemo({super.key});

  @override
  State<PushNotificationDemo> createState() => _PushNotificationDemoState();
}

class _PushNotificationDemoState extends State<PushNotificationDemo> {
  final NotificationService _notificationService = NotificationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<NotificationData> _notificationHistory = [];
  List<String> _subscribedTopics = [];
  bool _isLoading = true;
  String? _statusMessage;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _setupNotificationListeners();
    _loadNotificationHistory();
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Initializing notifications...';
      });

      await _notificationService.initialize();
      
      setState(() {
        _fcmToken = _notificationService.fcmToken;
        _isLoading = false;
        _statusMessage = 'Notifications initialized successfully';
      });

      // Load subscribed topics
      _loadSubscribedTopics();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error initializing notifications: $e';
      });
    }
  }

  void _setupNotificationListeners() {
    // Listen to foreground messages
    _notificationService.foregroundMessages.listen((message) {
      _addNotificationToHistory(message);
      _showNotificationDialog(message, 'Foreground Message');
    });

    // Listen to background messages
    _notificationService.backgroundMessages.listen((message) {
      _addNotificationToHistory(message);
      _showNotificationDialog(message, 'Background Message');
    });

    // Listen to terminated state messages
    _notificationService.terminatedMessages.listen((message) {
      _addNotificationToHistory(message);
      _showNotificationDialog(message, 'Terminated State Message');
    });
  }

  void _addNotificationToHistory(message) {
    final notificationData = NotificationData.fromRemoteMessage(message);
    setState(() {
      _notificationHistory.insert(0, notificationData);
      // Keep only last 50 notifications
      if (_notificationHistory.length > 50) {
        _notificationHistory.removeLast();
      }
    });
  }

  Future<void> _loadNotificationHistory() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .get();

        setState(() {
          _notificationHistory = snapshot.docs
              .map((doc) => NotificationData.fromMap(doc.data()))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading notification history: $e');
    }
  }

  Future<void> _loadSubscribedTopics() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('topicSubscriptions')
            .where('subscribed', isEqualTo: true)
            .get();

        setState(() {
          _subscribedTopics = snapshot.docs
              .map((doc) => doc['topic'] as String)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading subscribed topics: $e');
    }
  }

  void _showNotificationDialog(RemoteMessage message, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.notification?.title != null) ...[
              Text(
                'Title: ${message.notification?.title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
            if (message.notification?.body != null) ...[
              Text('Body: ${message.notification?.body}'),
              const SizedBox(height: 8),
            ],
            if (message.data.isNotEmpty) ...[
              const Text(
                'Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...message.data.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    try {
      await _notificationService.sendTestNotification(
        title: 'Test Notification',
        body: 'This is a test notification from the Flutter app!',
        data: {
          'type': 'test',
          'screen': 'notifications',
          'itemId': 'test_123',
        },
      );
      
      setState(() {
        _statusMessage = 'Test notification sent (check Firebase Console)';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error sending test notification: $e';
      });
    }
  }

  Future<void> _subscribeToTopic(String topic) async {
    try {
      await _notificationService.subscribeToTopic(topic);
      setState(() {
        _statusMessage = 'Subscribed to topic: $topic';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error subscribing to topic: $e';
      });
    }
  }

  Future<void> _unsubscribeFromTopic(String topic) async {
    try {
      await _notificationService.unsubscribeFromTopic(topic);
      setState(() {
        _statusMessage = 'Unsubscribed from topic: $topic';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error unsubscribing from topic: $e';
      });
    }
  }

  void _showTopicDialog() {
    final TextEditingController topicController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscribe to Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter topic name:'),
            const SizedBox(height: 16),
            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                hintText: 'e.g., news, promotions, updates',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final topic = topicController.text.trim();
              if (topic.isNotEmpty) {
                _subscribeToTopic(topic);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildStatusRow('Permission Status', _notificationService.permissionStatus),
            _buildStatusRow('FCM Token', _fcmToken?.substring(0, 20) ?? 'Not available'),
            _buildStatusRow('Initialized', _notificationService.isInitialized.toString()),
            if (_statusMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _statusMessage!.contains('Error') 
                      ? Colors.red.shade50 
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.contains('Error') 
                        ? Colors.red.shade700 
                        : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendTestNotification,
                icon: const Icon(Icons.send),
                label: const Text('Send Test Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showTopicDialog,
                icon: const Icon(Icons.add_circle),
                label: const Text('Subscribe to Topic'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _loadNotificationHistory(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscribed Topics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_subscribedTopics.isEmpty)
              const Text('No topics subscribed yet')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _subscribedTopics.map((topic) {
                  return Chip(
                    label: Text(topic),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _unsubscribeFromTopic(topic),
                    backgroundColor: Colors.blue.shade100,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationHistory() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_notificationHistory.isEmpty)
              const Text('No notifications received yet')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notificationHistory.length,
                itemBuilder: (context, index) {
                  final notification = _notificationHistory[index];
                  return NotificationTile(notification: notification);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing notifications...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusCard(),
            _buildActionsCard(),
            _buildTopicsCard(),
            _buildNotificationHistory(),
          ],
        ),
      ),
    );
  }
}

/// Notification tile widget for displaying notification history
class NotificationTile extends StatelessWidget {
  final NotificationData notification;

  const NotificationTile({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.notifications, color: Colors.blue),
        title: Text(
          notification.title ?? 'No Title',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body ?? 'No Body'),
            if (notification.timestamp != null)
              Text(
                _formatTimestamp(notification.timestamp!),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (notification.data != null && notification.data!.isNotEmpty)
              const SizedBox(height: 4),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showNotificationDetails(context);
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _showNotificationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title ?? 'Notification'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (notification.body != null) ...[
                Text('Body: ${notification.body}'),
                const SizedBox(height: 16),
              ],
              if (notification.timestamp != null) ...[
                Text('Time: ${notification.timestamp!.toLocal()}'),
                const SizedBox(height: 16),
              ],
              if (notification.data != null && notification.data!.isNotEmpty) ...[
                const Text(
                  'Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...notification.data!.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
