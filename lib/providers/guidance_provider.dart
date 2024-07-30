import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleb_edu_platform/models/guidance_category_model.dart';

class GuidanceCategoriesNotifier extends StateNotifier<AsyncValue<List<GuidanceCategory>>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GuidanceCategoriesNotifier() : super(AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final querySnapshot = await _firestore.collection('guidance_categories').get();

      final categories = await Future.wait(querySnapshot.docs.map((doc) async {
        final category = GuidanceCategory.fromFirestore(doc);
        final subcategoriesSnapshot = await doc.reference.collection('subcategories').get();

        category.subcategories = await Future.wait(subcategoriesSnapshot.docs.map((subDoc) async {
          final subcategory = GuidanceSubcategory.fromFirestore(subDoc);
          final itemsSnapshot = await subDoc.reference.collection('items').get();

          subcategory.items = itemsSnapshot.docs.map((itemDoc) => GuidanceItem.fromFirestore(itemDoc)).toList();
          return subcategory;
        }));

        return category;
      }).toList());

      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCategory(GuidanceCategory category) async {
    try {
      final docRef = await _firestore.collection('guidance_categories').add(category.toMap());

      for (var subcategory in category.subcategories) {
        final subDocRef = await docRef.collection('subcategories').add(subcategory.toMap());

        for (var item in subcategory.items) {
          await subDocRef.collection('items').add(item.toMap());
        }
      }

      await loadCategories();
    } catch (e, stack) {
      print('Error adding category: $e');
      // Handle the error appropriately, e.g., show an error message
    }
  }

  Future<void> updateCategory(GuidanceCategory category) async {
    try {
      await _firestore.collection('guidance_categories').doc(category.id).update(category.toMap());
      await loadCategories();
    } catch (e, stack) {
      print('Error updating category: $e');
      // Handle the error appropriately
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('guidance_categories').doc(id).delete();
      await loadCategories();
    } catch (e, stack) {
      print('Error deleting category: $e');
      // Handle the error appropriately
    }
  }
}

final guidanceCategoriesProvider = StateNotifierProvider<GuidanceCategoriesNotifier, AsyncValue<List<GuidanceCategory>>>((ref) {
  return GuidanceCategoriesNotifier();
});