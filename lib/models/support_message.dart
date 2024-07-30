import 'package:cloud_firestore/cloud_firestore.dart';

class SupportMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isAdminMessage;

  SupportMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isAdminMessage = false,
  });

  factory SupportMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return SupportMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isAdminMessage: data['isAdminMessage'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isAdminMessage': isAdminMessage,
    };
  }

  SupportMessage copyWith({
    String? id,
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? isAdminMessage,
  }) {
    return SupportMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isAdminMessage: isAdminMessage ?? this.isAdminMessage,
    );
  }

  @override
  String toString() {
    return 'SupportMessage(id: $id, senderId: $senderId, content: $content, timestamp: $timestamp, isAdminMessage: $isAdminMessage)';
  }
}