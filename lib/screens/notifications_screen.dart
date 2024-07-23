import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserNotification {
  final String title;
  final String body;
  final DateTime timestamp;
  bool seen;

  UserNotification({
    required this.title,
    required this.body,
    required this.timestamp,
    this.seen = false,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'seen': seen,
  };

  factory UserNotification.fromJson(Map<String, dynamic> json) => UserNotification(
    title: json['title'],
    body: json['body'],
    timestamp: DateTime.parse(json['timestamp']),
    seen: json['seen'] ?? false,
  );
}

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<UserNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList('notifications') ?? [];
    setState(() {
      notifications = notificationsJson
          .map((json) => UserNotification.fromJson(jsonDecode(json)))
          .toList();
    });
    _markAllAsSeen();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = notifications
        .map((notification) => jsonEncode(notification.toJson()))
        .toList();
    await prefs.setStringList('notifications', notificationsJson);
  }

  void addNotification(UserNotification notification) {
    setState(() {
      notifications.insert(0, notification);
    });
    _saveNotifications();
  }

  void _markAllAsSeen() {
    for (var notification in notifications) {
      notification.seen = true;
    }
    _saveNotifications();
  }

  static Future<int> getUnseenNotificationsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList('notifications') ?? [];
    final notifications = notificationsJson
        .map((json) => UserNotification.fromJson(jsonDecode(json)))
        .toList();
    return notifications.where((notification) => !notification.seen).length;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            'الإشعارات',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: notifications.isEmpty
            ? Center(
                child: Text(
                  'لا توجد إشعارات',
                  style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          notification.title,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              notification.body,
                              style: GoogleFonts.cairo(),
                            ),
                            SizedBox(height: 8),
                            Text(
                              DateFormat.yMMMd().add_jm().format(notification.timestamp),
                              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}