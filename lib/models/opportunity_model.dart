import 'package:cloud_firestore/cloud_firestore.dart';

class Opportunity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime deadline;
  final String category;
  final String organizationName;

  Opportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.deadline,
    required this.category,
    required this.organizationName,
  });

  factory Opportunity.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Opportunity(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      category: data['category'] ?? '',
      organizationName: data['organizationName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'deadline': Timestamp.fromDate(deadline),
      'category': category,
      'organizationName': organizationName,
    };
  }
}