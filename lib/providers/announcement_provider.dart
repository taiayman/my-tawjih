import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleb_edu_platform/models/announcement_model.dart';

class AnnouncementNotifier extends StateNotifier<AsyncValue<List<Announcement>>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  final int _pageSize = 10;

  AnnouncementNotifier() : super(AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = AsyncValue.loading();
    _lastDocument = null;
    _hasMore = true;
    await _loadAnnouncements();
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    await _loadAnnouncements();
  }

Future<void> _loadAnnouncements() async {
  try {
    print("Starting to load announcements");
    Query query = _firestore.collection('announcements')
        .orderBy('date', descending: true)
        .limit(_pageSize);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final querySnapshot = await query.get();
    print("Announcement query executed. Document count: ${querySnapshot.docs.length}");

    if (querySnapshot.docs.isEmpty) {
      _hasMore = false;
      print("No more announcements to load");
      // Update the state to an empty list when no announcements are found
      state = AsyncValue.data([]);
      return;
    }

    final newAnnouncements = querySnapshot.docs
        .map((doc) => Announcement.fromFirestore(doc))
        .toList();

    _lastDocument = querySnapshot.docs.last;

    state = AsyncValue.data([
      ...state.value ?? [],
      ...newAnnouncements,
    ]);

    _hasMore = querySnapshot.docs.length == _pageSize;
    print("Announcements loaded successfully. Total count: ${state.value?.length}");
  } catch (e, stack) {
    print('Error loading announcements: $e');
    print('Stack trace: $stack');
    state = AsyncValue.error(e, stack);
  }
}

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    await _firestore.collection('announcements').add(announcement.toMap());
    await loadInitial();
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    await _firestore.collection('announcements').doc(announcement.id).update(announcement.toMap());
    state = AsyncValue.data(state.value?.map((a) => a.id == announcement.id ? announcement : a).toList() ?? []);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('announcements').doc(id).delete();
    state = AsyncValue.data(state.value?.where((a) => a.id != id).toList() ?? []);
  }
}

final announcementNotifierProvider = StateNotifierProvider<AnnouncementNotifier, AsyncValue<List<Announcement>>>((ref) {
  return AnnouncementNotifier();
});

// Use this provider to access the announcements
final announcementsProvider = Provider<AsyncValue<List<Announcement>>>((ref) {
  return ref.watch(announcementNotifierProvider);
});