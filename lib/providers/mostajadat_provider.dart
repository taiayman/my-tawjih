import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/models/mostajadat_modal.dart';
import 'package:taleb_edu_platform/services/firestore_service.dart';

final mostajadatProvider = FutureProvider<List<Mostajadat>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getMostajadat();
});

final filteredMostajadatProvider = Provider.family<List<Mostajadat>, MostajadatFilter>((ref, filter) {
  final mostajadatAsyncValue = ref.watch(mostajadatProvider);
  return mostajadatAsyncValue.when(
    data: (mostajadat) {
      final filteredMostajadat = mostajadat.where((m) =>
          (filter.searchQuery.isEmpty ||
              m.title.toLowerCase().contains(filter.searchQuery.toLowerCase())) &&
          (filter.category == 'All' || m.category == filter.category)).toList();

      // Return an empty list if no matching mostajadat are found
      return filteredMostajadat.isEmpty ? [] : filteredMostajadat;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class MostajadatFilter {
  final String searchQuery;
  final String category;

  MostajadatFilter({
    this.searchQuery = '',
    this.category = 'All',
  });

  MostajadatFilter copyWith({
    String? searchQuery,
    String? category,
  }) {
    return MostajadatFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
    );
  }
}

final mostajadatFilterProvider = StateProvider<MostajadatFilter>((ref) => MostajadatFilter());

final addMostajadatProvider = FutureProvider.family<void, Mostajadat>((ref, mostajadat) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  await firestoreService.addDocument('mostajadat', mostajadat.toMap());
  ref.refresh(mostajadatProvider);
});

final updateMostajadatProvider = FutureProvider.family<void, Mostajadat>((ref, mostajadat) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  await firestoreService.updateDocument('mostajadat', mostajadat.id, mostajadat.toMap());
  ref.refresh(mostajadatProvider);
});

final deleteMostajadatProvider = FutureProvider.family<void, String>((ref, id) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  await firestoreService.deleteDocument('mostajadat', id);
  ref.refresh(mostajadatProvider);
});