import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

/// Firebase Cloud Messaging Service
/// 
/// Handles push notifications for foreground, background, and terminated states.
/// Provides methods for permission management, token handling, and message processing.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Notification stream controllers
  final StreamController<RemoteMessage> _foregroundMessageController = 
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _backgroundMessageController = 
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _terminatedMessageController = 
      StreamController<RemoteMessage>.broadcast();

  // Public streams
  Stream<RemoteMessage> get foregroundMessages => _foregroundMessageController.stream;
  Stream<RemoteMessage> get backgroundMessages => _backgroundMessageController.stream;
  Stream<RemoteMessage> get terminatedMessages => _terminatedMessageController.stream;

  // Notification settings
  NotificationSettings? _settings;
  String? _fcmToken;
  bool _isInitialized = false;

  // Getters
  NotificationSettings? get settings => _settings;
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await _requestPermissions();
      
      // Get initial message if app was opened from notification
      await _getInitialMessage();
      
      // Set up message handlers
      _setupMessageHandlers();
      
      // Get and save FCM token
      await _getAndSaveToken();
      
      // Listen for token refresh
      _setupTokenRefreshListener();
      
      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      rethrow;
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermissions() async {
    if (Platform.isIOS) {
      // Request iOS permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      _settings = settings;
      debugPrint('iOS notification settings: $settings');
      return settings;
    } else if (Platform.isAndroid) {
      // Request Android permissions
      await _requestAndroidPermissions();
      final settings = await _messaging.getNotificationSettings();
      _settings = settings;
      debugPrint('Android notification settings: $settings');
      return settings;
    }
    
    // Default for other platforms
    final settings = await _messaging.getNotificationSettings();
    _settings = settings;
    return settings;
  }

  /// Request Android notification permissions
  Future<void> _requestAndroidPermissions() async {
    if (Platform.isAndroid) {
      // Request notification permission for Android 13+
      if (await Permission.notification.isDenied) {
        final result = await Permission.notification.request();
        debugPrint('Android notification permission: $result');
      }
    }
  }

  /// Get initial message if app was opened from notification
  Future<void> _getInitialMessage() async {
    try {
      final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      
      if (initialMessage != null) {
        debugPrint('App opened from terminated state via notification');
        debugPrint('Message data: ${initialMessage.data}');
        debugPrint('Message notification: ${initialMessage.notification}');
        
        _terminatedMessageController.add(initialMessage);
        
        // Handle navigation based on message data
        _handleNotificationNavigation(initialMessage);
      }
    } catch (e) {
      debugPrint('Error getting initial message: $e');
    }
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Background messages (when app is in background but user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // Background message handler (for when app is in background)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Message title: ${message.notification?.title}');
    debugPrint('Message body: ${message.notification?.body}');
    debugPrint('Message data: ${message.data}');
    
    _foregroundMessageController.add(message);
    
    // Show in-app notification or update UI
    _showInAppNotification(message);
  }

  /// Handle background messages (when user taps notification)
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('App opened from background via notification');
    debugPrint('Message data: ${message.data}');
    debugPrint('Message notification: ${message.notification}');
    
    _backgroundMessageController.add(message);
    
    // Handle navigation based on message data
    _handleNotificationNavigation(message);
  }

  /// Show in-app notification for foreground messages
  void _showInAppNotification(RemoteMessage message) {
    // This would typically update UI or show a custom notification
    // For now, we'll just log it
    debugPrint('In-app notification: ${message.notification?.title}');
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(RemoteMessage message) {
    final String? screen = message.data['screen'];
    final String? itemId = message.data['itemId'];
    
    debugPrint('Navigating to screen: $screen, itemId: $itemId');
    
    // Navigation logic would be implemented here
    // This would typically use a navigation service or context
  }

  /// Get and save FCM token
  Future<void> _getAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      _fcmToken = token;
      
      debugPrint('FCM Token: $token');
      
      // Save token to Firestore for the current user
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
      
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem.toString(),
          'appVersion': '1.0.0', // This would come from your app version
        }, SetOptions(merge: true));
        
        debugPrint('FCM token saved to Firestore');
      }
    } catch (e) {
      debugPrint('Error saving token to Firestore: $e');
    }
  }

  /// Set up token refresh listener
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((token) {
      debugPrint('FCM Token refreshed: $token');
      _fcmToken = token;
      _saveTokenToFirestore(token);
    });
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
      
      // Save subscription to Firestore
      await _saveTopicSubscription(topic, true);
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
      
      // Save subscription to Firestore
      await _saveTopicSubscription(topic, false);
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Save topic subscription to Firestore
  Future<void> _saveTopicSubscription(String topic, bool subscribed) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('topicSubscriptions')
            .doc(topic)
            .set({
              'topic': topic,
              'subscribed': subscribed,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error saving topic subscription: $e');
    }
  }

  /// Get user's topic subscriptions
  Stream<QuerySnapshot<Map<String, dynamic>>> getTopicSubscriptions() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('topicSubscriptions')
          .where('subscribed', isEqualTo: true)
          .snapshots();
    }
    return const Stream.empty();
  }

  /// Send a test notification (for development)
  Future<void> sendTestNotification({
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // This would typically be done via a cloud function or server
      // For testing purposes, we'll just log it
      debugPrint('Test notification:');
      debugPrint('Title: $title');
      debugPrint('Body: $body');
      debugPrint('Data: $data');
      
      // In a real app, you would send this to your backend
      // which would then use FCM Admin SDK to send the notification
      
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  /// Clear notification streams
  void dispose() {
    _foregroundMessageController.close();
    _backgroundMessageController.close();
    _terminatedMessageController.close();
  }

  /// Check if notifications are enabled
  bool get areNotificationsEnabled {
    return _settings?.authorizationStatus == AuthorizationStatus.authorized ||
           _settings?.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Get notification permission status
  String get permissionStatus {
    switch (_settings?.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return 'Authorized';
      case AuthorizationStatus.denied:
        return 'Denied';
      case AuthorizationStatus.notDetermined:
        return 'Not Determined';
      case AuthorizationStatus.provisional:
        return 'Provisional';
      default:
        return 'Unknown';
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background handling
  await Firebase.initializeApp();
  
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification}');
  
  // Handle background message logic here
  // This could include:
  // - Processing data
  // - Updating local storage
  // - Scheduling local notifications
}

/// Notification data model
class NotificationData {
  final String? title;
  final String? body;
  final Map<String, String>? data;
  final DateTime? timestamp;

  NotificationData({
    this.title,
    this.body,
    this.data,
    this.timestamp,
  });

  factory NotificationData.fromRemoteMessage(RemoteMessage message) {
    return NotificationData(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data.cast<String, String>(),
      timestamp: message.sentTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      title: map['title'],
      body: map['body'],
      data: Map<String, String>.from(map['data'] ?? {}),
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp'])
          : null,
    );
  }
}

/// Notification types for different use cases
enum NotificationType {
  chat,
  order,
  reminder,
  promotion,
  system,
  update,
}

/// Notification helper class for creating different notification types
class NotificationHelper {
  static Map<String, String> createChatNotification({
    required String chatId,
    required String senderName,
    required String message,
  }) {
    return {
      'type': NotificationType.chat.name,
      'chatId': chatId,
      'senderName': senderName,
      'message': message,
      'screen': 'chat',
      'itemId': chatId,
    };
  }

  static Map<String, String> createOrderNotification({
    required String orderId,
    required String status,
    String? message,
  }) {
    return {
      'type': NotificationType.order.name,
      'orderId': orderId,
      'status': status,
      'message': message ?? 'Order status updated',
      'screen': 'order',
      'itemId': orderId,
    };
  }

  static Map<String, String> createReminderNotification({
    required String reminderId,
    required String title,
    required String description,
  }) {
    return {
      'type': NotificationType.reminder.name,
      'reminderId': reminderId,
      'title': title,
      'description': description,
      'screen': 'reminder',
      'itemId': reminderId,
    };
  }

  static Map<String, String> createPromotionNotification({
    required String promotionId,
    required String title,
    required String description,
  }) {
    return {
      'type': NotificationType.promotion.name,
      'promotionId': promotionId,
      'title': title,
      'description': description,
      'screen': 'promotion',
      'itemId': promotionId,
    };
  }

  static Map<String, String> createSystemNotification({
    required String title,
    required String message,
    String? screen,
    String? itemId,
  }) {
    return {
      'type': NotificationType.system.name,
      'title': title,
      'message': message,
      'screen': screen ?? 'home',
      'itemId': itemId ?? '',
    };
  }
}
