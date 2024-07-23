import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/models/message_model.dart';
import 'package:taleb_edu_platform/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageNotifier extends StateNotifier<List<Message>> {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MessageNotifier(this._firestoreService) : super([]) {
    _loadMessages();
  }

  void _loadMessages() {
    _firestoreService.getMessagesStream().listen((messages) {
      state = messages;
    });
  }

  Future<void> sendMessage(String text) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('Error: User not logged in.');
      return; // Or handle this case appropriately, e.g., show an error message
    }

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
      isFromUser: true,
      userId: currentUser.uid, // Get the userId from the logged-in user
    );

    await _firestoreService.addMessage(newMessage);
  }
}

final messageProvider = StateNotifierProvider<MessageNotifier, List<Message>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return MessageNotifier(firestoreService);
});