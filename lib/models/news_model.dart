import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String id;
  final String title;
  final String summary;
  final String content;
  final DateTime date;
  final String? imageUrl;
  final List<Reaction> reactions;
  final List<Map<String, dynamic>> comments;

  News({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.date,
    this.imageUrl,
    required this.reactions,
    required this.comments,
  });

  factory News.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return News(
      id: doc.id,
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      content: data['content'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      reactions: _parseReactions(data['reactions']),
      comments: _parseComments(data['comments']),
    );
  }

  static List<Reaction> _parseReactions(dynamic reactionsData) {
    if (reactionsData is List) {
      return reactionsData
          .map((r) => r is Map<String, dynamic> ? Reaction.fromMap(r) : Reaction(emoji: '', userId: ''))
          .toList();
    }
    return [];
  }

  static List<Map<String, dynamic>> _parseComments(dynamic commentsData) {
    if (commentsData is List) {
      return commentsData
          .map((c) => c is Map<String, dynamic> ? c : <String, dynamic>{})
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'reactions': reactions.map((r) => r.toMap()).toList(),
      'comments': comments,
    };
  }
}

class Reaction {
  final String emoji;
  final String userId;

  Reaction({required this.emoji, required this.userId});

  factory Reaction.fromMap(Map<String, dynamic> map) {
    return Reaction(
      emoji: map['emoji'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emoji': emoji,
      'userId': userId,
    };
  }
}
