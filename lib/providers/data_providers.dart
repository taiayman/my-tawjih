import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/models/news_model.dart';
import 'package:taleb_edu_platform/services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final recentNewsProvider = StreamProvider<List<News>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getCollectionStream('news').map((snapshot) =>
      snapshot.docs.map((doc) => News.fromFirestore(doc)).toList());
});
