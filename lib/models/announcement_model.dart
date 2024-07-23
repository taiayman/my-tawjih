import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String schoolImageUrl;
  final String schoolName;
  final String fullText;
  final String? officialDocumentUrl;
  final String? registrationLink;
  final Map<String, dynamic>? applicationDetails;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.schoolImageUrl,
    required this.schoolName,
    required this.fullText,
    this.officialDocumentUrl,
    this.registrationLink,
    this.applicationDetails,
  });

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      schoolImageUrl: data['schoolImageUrl'] ?? '',
      schoolName: data['schoolName'] ?? '',
      fullText: data['fullText'] ?? '',
      officialDocumentUrl: data['officialDocumentUrl'],
      registrationLink: data['registrationLink'],
      applicationDetails: data['applicationDetails'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'schoolImageUrl': schoolImageUrl,
      'schoolName': schoolName,
      'fullText': fullText,
      'officialDocumentUrl': officialDocumentUrl,
      'registrationLink': registrationLink,
      'applicationDetails': applicationDetails,
    };
  }
}