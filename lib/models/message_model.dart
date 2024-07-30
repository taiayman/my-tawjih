import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromUser;
  final String userId; // Add the userId property

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromUser,
    required this.userId, // Add userId to the constructor
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isFromUser: data['isFromUser'] ?? false,
      userId: data['userId'] ?? '', // Retrieve userId from Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isFromUser': isFromUser,
      'userId': userId, // Add userId to the map
    };
  }
}