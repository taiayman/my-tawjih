import 'package:flutter/foundation.dart';

enum TicketStatus { open, inProgress, resolved, closed }

class SupportTicket {
  final String id;
  final String userId;
  final List<TicketMessage> messages;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.messages,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  SupportTicket copyWith({
    String? id,
    String? userId,
    List<TicketMessage>? messages,
    TicketStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TicketMessage {
  final String senderId;
  final String content;
  final DateTime timestamp;

  TicketMessage({
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
}