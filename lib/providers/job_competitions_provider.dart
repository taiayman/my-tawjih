import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleb_edu_platform/models/announcement_model.dart';

class JobCompetitionsNotifier extends StateNotifier<List<Announcement>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  final int _pageSize = 10;

  JobCompetitionsNotifier() : super([]);

  Future<void> loadInitial() async {
    state = [];
    _lastDocument = null;
    _hasMore = true;
    await loadMore();
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;

    Query query = _firestore.collection('announcements')
        .where('category', isEqualTo: 'job_competition')
        .orderBy('date', descending: true)
        .limit(_pageSize);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final querySnapshot = await query.get();

    if (querySnapshot.docs.isEmpty) {
      _hasMore = false;
      return;
    }

    final newJobCompetitions = querySnapshot.docs
        .map((doc) => Announcement.fromFirestore(doc))
        .toList();

    _lastDocument = querySnapshot.docs.last;

    state = [...state, ...newJobCompetitions];

    _hasMore = querySnapshot.docs.length == _pageSize;
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> addJobCompetition(Announcement jobCompetition) async {
    await _firestore.collection('announcements').add(jobCompetition.toMap());
    await loadInitial();
  }

  Future<void> updateJobCompetition(Announcement jobCompetition) async {
    await _firestore.collection('announcements').doc(jobCompetition.id).update(jobCompetition.toMap());
    state = state.map((a) => a.id == jobCompetition.id ? jobCompetition : a).toList();
  }

  Future<void> deleteJobCompetition(String id) async {
    await _firestore.collection('announcements').doc(id).delete();
    state = state.where((a) => a.id != id).toList();
  }
}

final jobCompetitionsNotifierProvider = StateNotifierProvider<JobCompetitionsNotifier, List<Announcement>>((ref) {
  return JobCompetitionsNotifier();
});

final jobCompetitionsProvider = FutureProvider<List<Announcement>>((ref) async {
  final jobCompetitionsNotifier = ref.watch(jobCompetitionsNotifierProvider.notifier); 
  await jobCompetitionsNotifier.loadInitial();
  return ref.watch(jobCompetitionsNotifierProvider); 
});
