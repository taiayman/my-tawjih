import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleb_edu_platform/models/news_model.dart';
import 'package:taleb_edu_platform/services/firestore_service.dart';

final newsReactionsProvider = Provider.family<Future<void>, Map<String, dynamic>>((ref, data) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final String newsId = data['newsId'] as String;
  final Reaction newReaction = data['reaction'] as Reaction;
  
  print('Adding reaction ${newReaction.emoji} to news $newsId for user ${newReaction.userId}');
  
  try {
    DocumentReference newsRef = firestoreService.firestore.collection('news').doc(newsId);
    
    await firestoreService.firestore.runTransaction((transaction) async {
      DocumentSnapshot newsDoc = await transaction.get(newsRef);
      
      if (!newsDoc.exists) {
        throw Exception("News post does not exist!");
      }
      
      Map<String, dynamic> newsData = newsDoc.data() as Map<String, dynamic>;
      List<dynamic> reactionsData = newsData['reactions'] as List<dynamic>? ?? [];
      
      List<Map<String, dynamic>> reactions = reactionsData.map((r) {
        if (r is Map<String, dynamic>) {
          return r;
        } else if (r is String) {
          return {'emoji': r, 'userId': 'unknown'};
        } else {
          return {'emoji': '', 'userId': ''};
        }
      }).toList();
      
      // Remove existing reaction from the same user
      reactions.removeWhere((r) => r['userId'] == newReaction.userId);
      
      // Add new reaction
      reactions.add(newReaction.toMap());
      
      transaction.update(newsRef, {'reactions': reactions});
    });
    
    print('Reaction added successfully');
  } catch (e) {
    print('Error adding reaction: $e');
    throw e;
  }
});

final recentNewsProvider = StreamProvider<List<News>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getCollectionStream('news').map((snapshot) {
    List<News> newsList = [];
    for (var doc in snapshot.docs) {
      try {
        newsList.add(News.fromFirestore(doc));
      } catch (e, stack) {
        print('Error parsing news document ${doc.id}: $e');
        print('Stack trace: $stack');
      }
    }
    return newsList;
  });
});

final newsCommentsProvider = Provider.family<Future<void>, Map<String, dynamic>>((ref, data) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  String newsId = data['newsId'] as String;
  Map<String, dynamic> comment = data['comment'] as Map<String, dynamic>;
  
  print('Adding comment to news $newsId: $comment');
  
  try {
    DocumentReference newsRef = firestoreService.firestore.collection('news').doc(newsId);
    
    await newsRef.update({
      'comments': FieldValue.arrayUnion([comment])
    });
    
    print('Comment added successfully');
  } catch (e) {
    print('Error adding comment: $e');
    throw e;
  }
});
