// File: lib/providers/application_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/services/firestore_service.dart';

class ApplicationNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;

  ApplicationNotifier(this._firestoreService) : super(AsyncValue.data(null));

  Future<void> submitApplication({
    required String announcementId,
    required String name,
    required String email,
    required String phone,
    required String motivation,
  }) async {
    state = AsyncValue.loading();
    try {
      await _firestoreService.addApplication({
        'announcementId': announcementId,
        'name': name,
        'email': email,
        'phone': phone,
        'motivation': motivation,
        'timestamp': DateTime.now(),
      });
      state = AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final applicationProvider = StateNotifierProvider<ApplicationNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ApplicationNotifier(firestoreService);
});