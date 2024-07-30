import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/models/support_message.dart';
import 'package:taleb_edu_platform/models/support_ticket.dart';
import 'package:taleb_edu_platform/services/firestore_service.dart';

class SupportState {
  final List<SupportMessage> messages;
  final bool isLoading;
  final String? error;

  SupportState({
    required this.messages,
    this.isLoading = false,
    this.error,
  });

  SupportState copyWith({
    List<SupportMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return SupportState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SupportNotifier extends StateNotifier<SupportState> {
  final FirestoreService _firestoreService;

  SupportNotifier(this._firestoreService) : super(SupportState(messages: []));

  Future<void> loadMessages(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _firestoreService.getSupportMessages(userId);
      state = SupportState(
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load messages: $e',
      );
    }
  }

  Future<void> sendMessage(SupportMessage message) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newMessage = await _firestoreService.addSupportMessage(message);
      final updatedMessages = [...state.messages, newMessage];
      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send message: $e',
      );
    }
  }

  Future<void> sendMessageToTicket(String ticketId, TicketMessage message) async {
    try {
      await _firestoreService.addMessageToTicket(ticketId, message);
    } catch (e) {
      print('Error sending message to ticket: $e');
      throw Exception('Failed to send message to ticket: $e');
    }
  }

  Future<void> updateTicketStatus(String ticketId, TicketStatus newStatus) async {
    try {
      await _firestoreService.updateTicketStatus(ticketId, newStatus);
    } catch (e) {
      print('Error updating ticket status: $e');
      throw Exception('Failed to update ticket status: $e');
    }
  }

}

final supportProvider = StateNotifierProvider<SupportNotifier, SupportState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return SupportNotifier(firestoreService);
});


final supportTicketProvider = StreamProvider.family<SupportTicket, String>((ref, ticketId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getSupportTicket(ticketId);
});