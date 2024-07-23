import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fcmServiceProvider = Provider<FCMService>((ref) => FCMService());

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      List<String> tokens = snapshot.docs
          .map((doc) => doc.get('fcmToken') as String?)
          .where((token) => token != null)
          .cast<String>()
          .toList();

      for (String token in tokens) {
        await _sendNotification(token, title, body);
      }
    } catch (e) {
      print('Error sending notifications: $e');
      throw e;
    }
  }

  Future<void> _sendNotification(String token, String title, String body) async {
    try {
      await _firestore.collection('notifications').add({
        'token': token,
        'title': title,
        'body': body,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending individual notification: $e');
    }
  }
}