import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/models/education_pathway.dart';

class EducationPathwayNotifier extends StateNotifier<AsyncValue<List<EducationPathway>>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EducationPathwayNotifier() : super(AsyncValue.loading()) {
    loadPathways();
  }

  Future<void> deleteUniversity(String pathwayId, String specializationId, String universityId) async {
    try {
      final pathwayDoc = await _firestore.collection('education_pathways').doc(pathwayId).get();
      if (!pathwayDoc.exists) {
        throw Exception('Pathway not found');
      }

      final pathwayData = pathwayDoc.data() as Map<String, dynamic>;
      final specializations = (pathwayData['specializations'] as List? ?? []).map((spec) => Specialization.fromFirestore(spec)).toList();

      final specializationIndex = specializations.indexWhere((spec) => spec.id == specializationId);
      if (specializationIndex == -1) {
        throw Exception('Specialization not found');
      }

      specializations[specializationIndex].universities.removeWhere((uni) => uni.id == universityId);

      await _firestore.collection('education_pathways').doc(pathwayId).update({
        'specializations': specializations.map((spec) => spec.toMap()).toList(),
      });

      await loadPathways();
    } catch (e, stack) {
      print('Error deleting university: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadPathways() async {
    try {
      final querySnapshot = await _firestore.collection('education_pathways').get();
      final pathways = querySnapshot.docs.map((doc) => EducationPathway.fromFirestore(doc)).toList();
      state = AsyncValue.data(pathways);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addPathway(EducationPathway pathway) async {
    try {
      final docRef = await _firestore.collection('education_pathways').add(pathway.toMap());
      await loadPathways();
    } catch (e, stack) {
      print('Error adding pathway: $e');
    }
  }

  Future<void> updatePathway(EducationPathway pathway) async {
    try {
      await _firestore.collection('education_pathways').doc(pathway.id).update(pathway.toMap());
      await loadPathways();
    } catch (e, stack) {
      print('Error updating pathway: $e');
    }
  }

  Future<void> deletePathway(String id) async {
    try {
      await _firestore.collection('education_pathways').doc(id).delete();
      await loadPathways();
    } catch (e, stack) {
      print('Error deleting pathway: $e');
    }
  }

  Future<void> updateUniversity(String pathwayId, String specializationId, University university) async {
    try {
      final pathwayDoc = await _firestore.collection('education_pathways').doc(pathwayId).get();
      if (!pathwayDoc.exists) {
        throw Exception('Pathway not found');
      }

      final pathwayData = pathwayDoc.data() as Map<String, dynamic>;
      final specializations = (pathwayData['specializations'] as List? ?? []).map((spec) => Specialization.fromFirestore(spec)).toList();

      final specializationIndex = specializations.indexWhere((spec) => spec.id == specializationId);
      if (specializationIndex == -1) {
        throw Exception('Specialization not found');
      }

      final universityIndex = specializations[specializationIndex].universities.indexWhere((uni) => uni.id == university.id);
      if (universityIndex == -1) {
        // Add new university
        specializations[specializationIndex].universities.add(university);
      } else {
        // Update existing university
        specializations[specializationIndex].universities[universityIndex] = university;
      }

      await _firestore.collection('education_pathways').doc(pathwayId).update({
        'specializations': specializations.map((spec) => spec.toMap()).toList(),
      });

      await loadPathways();
    } catch (e, stack) {
      print('Error updating university: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addSpecialization(String pathwayId, Specialization specialization) async {
    try {
      final pathwayDoc = await _firestore.collection('education_pathways').doc(pathwayId).get();
      if (!pathwayDoc.exists) {
        throw Exception('Pathway not found');
      }

      final pathwayData = pathwayDoc.data() as Map<String, dynamic>;
      final specializations = (pathwayData['specializations'] as List? ?? []).map((spec) => Specialization.fromFirestore(spec)).toList();

      specializations.add(specialization);

      await _firestore.collection('education_pathways').doc(pathwayId).update({
        'specializations': specializations.map((spec) => spec.toMap()).toList(),
      });

      await loadPathways();
    } catch (e, stack) {
      print('Error adding specialization: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSpecialization(String pathwayId, Specialization specialization) async {
    try {
      final pathwayDoc = await _firestore.collection('education_pathways').doc(pathwayId).get();
      if (!pathwayDoc.exists) {
        throw Exception('Pathway not found');
      }

      final pathwayData = pathwayDoc.data() as Map<String, dynamic>;
      final specializations = (pathwayData['specializations'] as List? ?? []).map((spec) => Specialization.fromFirestore(spec)).toList();

      final index = specializations.indexWhere((spec) => spec.id == specialization.id);
      if (index == -1) {
        throw Exception('Specialization not found');
      }

      specializations[index] = specialization;

      await _firestore.collection('education_pathways').doc(pathwayId).update({
        'specializations': specializations.map((spec) => spec.toMap()).toList(),
      });

      await loadPathways();
    } catch (e, stack) {
      print('Error updating specialization: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteSpecialization(String pathwayId, String specializationId) async {
    try {
      final pathwayDoc = await _firestore.collection('education_pathways').doc(pathwayId).get();
      if (!pathwayDoc.exists) {
        throw Exception('Pathway not found');
      }

      final pathwayData = pathwayDoc.data() as Map<String, dynamic>;
      final specializations = (pathwayData['specializations'] as List? ?? []).map((spec) => Specialization.fromFirestore(spec)).toList();

      specializations.removeWhere((spec) => spec.id == specializationId);

      await _firestore.collection('education_pathways').doc(pathwayId).update({
        'specializations': specializations.map((spec) => spec.toMap()).toList(),
      });

      await loadPathways();
    } catch (e, stack) {
      print('Error deleting specialization: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  
}

final educationPathwayProvider = StateNotifierProvider<EducationPathwayNotifier, AsyncValue<List<EducationPathway>>>((ref) {
  return EducationPathwayNotifier();
});