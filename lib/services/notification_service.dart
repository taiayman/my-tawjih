import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taleb_edu_platform/services/firestore_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService;
  final String _oneSignalRestApiKey = "OWNlYjlmYWUtNThlNS00ZjQ1LTk5ZTctOTc2OTRjNWJkODAy";
  final String _oneSignalAppId = "3b76c84e-346f-4ee7-8e8f-ae54a407bc92";

  NotificationService(this._firestoreService);

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();

    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveTokenLocally(token);
      await _saveTokenToFirestore(token);
    }

    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      await _saveTokenLocally(token);
      await _saveTokenToFirestore(token);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received foreground message: ${message.messageId}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Opened app from background state: ${message.messageId}");
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setAppId(_oneSignalAppId);

    setupOneSignalHandlers();
  }

  void setupOneSignalHandlers() {
    OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
      print("Notification received in foreground: ${event.notification.body}");
      event.complete(event.notification);
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print("Opened notification: ${result.notification.body}");
      handleNotificationResponse(result);
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("Permission state changed: ${changes.to.status}");
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("Subscription state changed: ${changes.to.userId != null}");
    });

    OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges changes) {
      print("Email subscription state changed: ${changes.to.emailUserId != null}");
    });
  }

  Future<void> setOneSignalExternalUserId(String userId) async {
    await OneSignal.shared.setExternalUserId(userId);
  }

  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> _saveTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  Future<String?> getLocalToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  Future<void> _saveTokenToFirestore(String token) async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<void> updateTokenForUser(String userId) async {
    String? token = await getLocalToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> sendNotificationToAllUsers({
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final notification = {
        "app_id": _oneSignalAppId,
        "contents": {"en": body},
        "headings": {"en": title},
        "included_segments": ["All"],
        "data": additionalData,
      };

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          "Authorization": "Basic $_oneSignalRestApiKey",
          "Content-Type": "application/json"
        },
        body: jsonEncode(notification),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send notification: ${response.body}');
      }

      print("Notification sent successfully: ${response.body}");

    } catch (e) {
      print('Error sending notifications: $e');
      throw e;
    }
  }

  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      String? token = userDoc.get('fcmToken') as String?;
      if (token != null) {
        final notification = {
          "app_id": _oneSignalAppId,
          "contents": {"en": body},
          "headings": {"en": title},
          "include_player_ids": [token],
          "data": additionalData,
        };

        final response = await http.post(
          Uri.parse('https://onesignal.com/api/v1/notifications'),
          headers: {
            "Authorization": "Basic $_oneSignalRestApiKey",
            "Content-Type": "application/json"
          },
          body: jsonEncode(notification),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to send notification: ${response.body}');
        }

        print("Notification sent successfully: ${response.body}");
      }
    } catch (e) {
      print('Error sending notification to user: $e');
      throw e;
    }
  }

  void handleNotificationResponse(OSNotificationOpenedResult result) {
    Map<String, dynamic>? additionalData = result.notification.additionalData;
    if (additionalData != null && additionalData.containsKey('type')) {
      switch (additionalData['type']) {
        case 'news':
          break;
        case 'announcement':
          break;
        case 'message':
          break;
        default:
          break;
      }
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return NotificationService(firestoreService);
});