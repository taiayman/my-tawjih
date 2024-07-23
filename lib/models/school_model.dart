// File: lib/models/school_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class School {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final List<String> programs;
  final Map<String, dynamic> admissionRequirements;

  School({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.programs,
    required this.admissionRequirements,
  });

  factory School.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return School(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      programs: List<String>.from(data['programs'] ?? []),
      admissionRequirements: Map<String, dynamic>.from(data['admissionRequirements'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'programs': programs,
      'admissionRequirements': admissionRequirements,
    };
  }
}