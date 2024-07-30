import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/models/announcement_model.dart';
import 'package:taleb_edu_platform/models/message_model.dart';
import 'package:taleb_edu_platform/models/mostajadat_modal.dart';
import 'package:taleb_edu_platform/models/news_model.dart';
import 'package:taleb_edu_platform/models/school_model.dart';
import 'package:taleb_edu_platform/models/support_ticket.dart';
import 'package:taleb_edu_platform/models/support_message.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  Future<void> setDocument(String collection, String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
      print('Document set in $collection with ID: $documentId');
    } catch (e) {
      print('Error setting document: $e');
      throw Exception('Failed to set document: $e');
    }
  }

  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      DocumentReference docRef = await _firestore.collection(collection).add(data);
      print('Document added to $collection with ID: ${docRef.id}');
    } catch (e) {
      print('Error adding document: $e');
      throw Exception('Failed to add document: $e');
    }
  }

  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data) async {
    try {
      DocumentReference docRef = _firestore.collection(collection).doc(documentId);
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update(data);
        print('Document updated in $collection: $documentId');
      } else {
        print('Document $documentId does not exist in collection $collection.');
        throw Exception('Document not found');
      }
    } catch (e) {
      print('Error updating document: $e');
      throw Exception('Failed to update document: $e');
    }
  }

  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      print('Document deleted from $collection: $documentId');
    } catch (e) {
      print('Error deleting document: $e');
      throw Exception('Failed to delete document: $e');
    }
  }

  Future<DocumentSnapshot> getDocument(String collection, String documentId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(collection).doc(documentId).get();
      print('Document retrieved from $collection: $documentId');
      return doc;
    } catch (e) {
      print('Error getting document: $e');
      throw Exception('Failed to get document: $e');
    }
  }

  Future<QuerySnapshot> getCollection(String collection) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collection).get();
      print('Collection retrieved: $collection');
      return querySnapshot;
    } catch (e) {
      print('Error getting collection: $e');
      throw Exception('Failed to get collection: $e');
    }
  }

  Future<QuerySnapshot> queryCollection(String collection, List<List<dynamic>> conditions) async {
    try {
      Query query = _firestore.collection(collection);
      for (var condition in conditions) {
        query = query.where(condition[0], isEqualTo: condition[1]);
      }
      QuerySnapshot querySnapshot = await query.get();
      print('Query executed on collection: $collection');
      return querySnapshot;
    } catch (e) {
      print('Error querying collection: $e');
      throw Exception('Failed to query collection: $e');
    }
  }

  Stream<List<Message>> getMessagesStream() {
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  Future<void> addMessage(Message message) async {
    try {
      await _firestore.collection('messages').add(message.toMap());
    } catch (e) {
      print('Error adding message: $e');
      throw Exception('Failed to add message: $e');
    }
  }

  Future<List<School>> getSchools() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('schools').get();
      return snapshot.docs.map((doc) => School.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching schools: $e');
      throw Exception('Failed to fetch schools: $e');
    }
  }

  Future<void> addApplication(Map<String, dynamic> applicationData) async {
    try {
      await _firestore.collection('applications').add(applicationData);
    } catch (e) {
      print('Error adding application: $e');
      throw Exception('Failed to submit application: $e');
    }
  }

  Future<List<News>> getRecentNews() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('news')
          .orderBy('date', descending: true)
          .limit(5)
          .get();
      return snapshot.docs.map((doc) => News.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching recent news: $e');
      throw Exception('Failed to fetch recent news: $e');
    }
  }

  Future<void> addReactionToNews(String newsId, String reaction, String userId) async {
    DocumentReference newsRef = _firestore.collection('news').doc(newsId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot newsDoc = await transaction.get(newsRef);

      if (!newsDoc.exists) {
        throw Exception("News post does not exist!");
      }

      Map<String, dynamic> data = newsDoc.data() as Map<String, dynamic>;
      List<Map<String, dynamic>> reactions = List<Map<String, dynamic>>.from(data['reactions'] ?? []);

      reactions.removeWhere((r) => r['userId'] == userId);

      reactions.add({
        'emoji': reaction,
        'userId': userId,
      });

      transaction.update(newsRef, {'reactions': reactions});
    });
  }

  Future<void> addCommentToNews(String newsId, Map<String, dynamic> comment) async {
    DocumentReference newsRef = _firestore.collection('news').doc(newsId);
    await newsRef.update({
      'comments': FieldValue.arrayUnion([comment])
    });
  }

Future<List<Mostajadat>> getMostajadat() async {
  try {
    print("Fetching mostajadat...");
    QuerySnapshot snapshot = await _firestore
        .collection('mostajadat')
        .orderBy('date', descending: true)
        .get();
    print("Mostajadat fetched. Document count: ${snapshot.docs.length}");
    return snapshot.docs.map((doc) => Mostajadat.fromFirestore(doc)).toList();
  } catch (e) {
    print('Error fetching mostajadat: $e');
    throw Exception('Failed to fetch mostajadat: $e');
  }
}

  Future<List<Announcement>> getAnnouncements() async {
  try {
    print("Fetching announcements...");
    QuerySnapshot snapshot = await _firestore.collection('announcements').get();
    print("Announcements fetched. Document count: ${snapshot.docs.length}");
    return snapshot.docs.map((doc) => Announcement.fromFirestore(doc)).toList();
  } catch (e) {
    print('Error fetching announcements: $e');
    rethrow; // Re-throw the error to be handled by the calling code
  }
}



  Stream<List<SupportTicket>> getAllSupportTickets() {
    return _firestore.collection('support_tickets').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _ticketFromFirestore(doc)).toList();
    });
  }

  Stream<SupportTicket> getSupportTicket(String ticketId) {
    return _firestore.collection('support_tickets').doc(ticketId).snapshots().map(_ticketFromFirestore);
  }

  Future<List<SupportTicket>> getUserTickets(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('support_tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => _ticketFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching user tickets: $e');
      throw Exception('Failed to fetch user tickets: $e');
    }
  }

  Future<SupportTicket> createSupportTicket(String userId) async {
    try {
      DocumentReference docRef = await _firestore.collection('support_tickets').add({
        'userId': userId,
        'status': TicketStatus.open.toString(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'messages': [],
      });

      DocumentSnapshot doc = await docRef.get();
      return _ticketFromFirestore(doc);
    } catch (e) {
      print('Error creating support ticket: $e');
      throw Exception('Failed to create support ticket: $e');
    }
  }

  Future<SupportTicket> addMessageToTicket(String ticketId, TicketMessage message) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'messages': FieldValue.arrayUnion([{
          'senderId': message.senderId,
          'content': message.content,
          'timestamp': message.timestamp.toIso8601String(),
        }]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      DocumentSnapshot doc = await _firestore.collection('support_tickets').doc(ticketId).get();
      return _ticketFromFirestore(doc);
    } catch (e) {
      print('Error adding message to ticket: $e');
      throw Exception('Failed to add message to ticket: $e');
    }
  }

  Future<SupportTicket> updateTicketStatus(String ticketId, TicketStatus newStatus) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'status': newStatus.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      DocumentSnapshot doc = await _firestore.collection('support_tickets').doc(ticketId).get();
      return _ticketFromFirestore(doc);
    } catch (e) {
      print('Error updating ticket status: $e');
      throw Exception('Failed to update ticket status: $e');
    }
  }

  Future<SupportTicket> closeTicket(String ticketId) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'status': TicketStatus.closed.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      DocumentSnapshot doc = await _firestore.collection('support_tickets').doc(ticketId).get();
      return _ticketFromFirestore(doc);
    } catch (e) {
      print('Error closing ticket: $e');
      throw Exception('Failed to close ticket: $e');
    }
  }

  Future<List<SupportMessage>> getSupportMessages(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('support_messages')
          .where('senderId', isEqualTo: userId)
          .orderBy('timestamp')
          .get();

      return snapshot.docs.map((doc) => SupportMessage.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching support messages: $e');
      throw Exception('Failed to fetch support messages: $e');
    }
  }

  Future<SupportMessage> addSupportMessage(SupportMessage message) async {
    try {
      DocumentReference docRef = await _firestore.collection('support_messages').add(message.toMap());
      DocumentSnapshot docSnapshot = await docRef.get();
      return SupportMessage.fromFirestore(docSnapshot);
    } catch (e) {
      print('Error adding support message: $e');
      throw Exception('Failed to add support message: $e');
    }
  }

  SupportTicket _ticketFromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SupportTicket(
      id: doc.id,
      userId: data['userId'],
      messages: (data['messages'] as List<dynamic>? ?? []).map((m) => TicketMessage(
        senderId: m['senderId'],
        content: m['content'],
        timestamp: DateTime.parse(m['timestamp']),
      )).toList(),
      status: TicketStatus.values.firstWhere((e) => e.toString() == data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
