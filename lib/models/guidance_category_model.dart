import 'package:cloud_firestore/cloud_firestore.dart';

class GuidanceCategory {
  final String id;
  final String name;
  List<GuidanceSubcategory> subcategories;

  GuidanceCategory({
    required this.id,
    required this.name,
    required this.subcategories,
  });

  factory GuidanceCategory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GuidanceCategory(
      id: doc.id,
      name: data['name'] ?? '',
      subcategories: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

class GuidanceSubcategory {
  final String id;
  final String name;
  List<GuidanceItem> items;

  GuidanceSubcategory({
    required this.id,
    required this.name,
    required this.items,
  });

  factory GuidanceSubcategory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GuidanceSubcategory(
      id: doc.id,
      name: data['name'] ?? '',
      items: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

class GuidanceItem {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;

  GuidanceItem({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  factory GuidanceItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GuidanceItem(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}