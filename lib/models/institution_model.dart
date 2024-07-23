import 'package:cloud_firestore/cloud_firestore.dart';

class Institution {
  final String id;
  final String name;
  final String description;
  final List<UniversityCategory> categories;

  Institution({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
  });

  factory Institution.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Institution(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      categories: (data['categories'] as List? ?? [])
          .map((c) => UniversityCategory.fromMap(c))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'categories': categories.map((c) => c.toMap()).toList(),
    };
  }
}

class UniversityCategory {
  final String id;
  final String name;
  final List<Faculty> faculties;

  UniversityCategory({
    required this.id,
    required this.name,
    required this.faculties,
  });

  factory UniversityCategory.fromMap(Map<String, dynamic> map) {
    return UniversityCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      faculties: (map['faculties'] as List? ?? [])
          .map((f) => Faculty.fromMap(f))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'faculties': faculties.map((f) => f.toMap()).toList(),
    };
  }
}

class Faculty {
  final String id;
  final String name;
  final String description;

  Faculty({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Faculty.fromMap(Map<String, dynamic> map) {
    return Faculty(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}