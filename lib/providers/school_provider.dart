// File: lib/providers/school_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/models/school_model.dart';
import 'package:taleb_edu_platform/services/firestore_service.dart';

final schoolProvider = FutureProvider<List<School>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getSchools();
});