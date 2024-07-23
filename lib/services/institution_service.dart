import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleb_edu_platform/models/institution_model.dart';

class InstitutionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Institution>> getInstitutions() async {
    QuerySnapshot snapshot = await _firestore.collection('institutions').get();
    return snapshot.docs.map((doc) => Institution.fromFirestore(doc)).toList();
  }

  Future<void> addInstitution(Institution institution) async {
    await _firestore.collection('institutions').add(institution.toMap());
  }

  Future<void> updateInstitution(Institution institution) async {
    await _firestore.collection('institutions').doc(institution.id).update(institution.toMap());
  }

  Future<void> deleteInstitution(String id) async {
    await _firestore.collection('institutions').doc(id).delete();
  }

  Future<void> addCategory(String institutionId, UniversityCategory category) async {
    DocumentReference institutionRef = _firestore.collection('institutions').doc(institutionId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(institutionRef);
      if (snapshot.exists) {
        List<dynamic> categories = List.from(snapshot.get('categories') ?? []);
        categories.add(category.toMap());
        transaction.update(institutionRef, {'categories': categories});
      }
    });
  }

  Future<void> updateCategory(String institutionId, UniversityCategory category) async {
    DocumentReference institutionRef = _firestore.collection('institutions').doc(institutionId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(institutionRef);
      if (snapshot.exists) {
        List<dynamic> categories = List.from(snapshot.get('categories') ?? []);
        int categoryIndex = categories.indexWhere((c) => c['id'] == category.id);
        if (categoryIndex != -1) {
          categories[categoryIndex] = category.toMap();
          transaction.update(institutionRef, {'categories': categories});
        }
      }
    });
  }

  Future<void> deleteCategory(String institutionId, String categoryId) async {
    DocumentReference institutionRef = _firestore.collection('institutions').doc(institutionId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(institutionRef);
      if (snapshot.exists) {
        List<dynamic> categories = List.from(snapshot.get('categories') ?? []);
        categories.removeWhere((c) => c['id'] == categoryId);
        transaction.update(institutionRef, {'categories': categories});
      }
    });
  }

  Future<void> addFaculty(String institutionId, String categoryId, Faculty faculty) async {
    DocumentReference institutionRef = _firestore.collection('institutions').doc(institutionId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(institutionRef);
      if (snapshot.exists) {
        List<dynamic> categories = List.from(snapshot.get('categories') ?? []);
        int categoryIndex = categories.indexWhere((c) => c['id'] == categoryId);
        if (categoryIndex != -1) {
          List<dynamic> faculties = List.from(categories[categoryIndex]['faculties'] ?? []);
          faculties.add(faculty.toMap());
          categories[categoryIndex]['faculties'] = faculties;
          transaction.update(institutionRef, {'categories': categories});
        }
      }
    });
  }

  Future<void> updateFaculty(String institutionId, String categoryId, Faculty faculty) async {
    DocumentReference institutionRef = _firestore.collection('institutions').doc(institutionId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(institutionRef);
      if (snapshot.exists) {
        List<dynamic> categories = List.from(snapshot.get('categories') ?? []);
        int categoryIndex = categories.indexWhere((c) => c['id'] == categoryId);
        if (categoryIndex != -1) {
          List<dynamic> faculties = List.from(categories[categoryIndex]['faculties'] ?? []);
          int facultyIndex = faculties.indexWhere((f) => f['id'] == faculty.id);
          if (facultyIndex != -1) {
            faculties[facultyIndex] = faculty.toMap();
            categories[categoryIndex]['faculties'] = faculties;
            transaction.update(institutionRef, {'categories': categories});
          }
        }
      }
    });
  }

  Future<void> deleteFaculty(String institutionId, String categoryId, String facultyId) async {
    DocumentReference institutionRef = _firestore.collection('institutions').doc(institutionId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(institutionRef);
      if (snapshot.exists) {
        List<dynamic> categories = List.from(snapshot.get('categories') ?? []);
        int categoryIndex = categories.indexWhere((c) => c['id'] == categoryId);
        if (categoryIndex != -1) {
          List<dynamic> faculties = List.from(categories[categoryIndex]['faculties'] ?? []);
          faculties.removeWhere((f) => f['id'] == facultyId);
          categories[categoryIndex]['faculties'] = faculties;
          transaction.update(institutionRef, {'categories': categories});
        }
      }
    });
  }
}