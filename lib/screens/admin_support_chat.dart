import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taleb_edu_platform/models/support_ticket.dart';
import 'package:taleb_edu_platform/providers/support_provider.dart';
import 'package:intl/intl.dart';
import 'package:taleb_edu_platform/widgets/chat_bubble.dart';

class AdminSupportChat extends ConsumerStatefulWidget {
  final String ticketId;

  AdminSupportChat({required this.ticketId});

  @override
  _AdminSupportChatState createState() => _AdminSupportChatState();
}

class _AdminSupportChatState extends ConsumerState<AdminSupportChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      ref.read(supportProvider.notifier).sendMessageToTicket(
        widget.ticketId,
        TicketMessage(
          senderId: 'admin',
          content: _messageController.text.trim(),
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final supportTicketAsync = ref.watch(supportTicketProvider(widget.ticketId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Support Chat'),
        backgroundColor: Color(0xFF2196F3),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => supportTicketAsync.whenData((ticket) => _showTicketInfo(context, ticket)),
          ),
        ],
      ),
      body: supportTicketAsync.when(
        data: (supportTicket) => Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE3F2FD),
                      Color(0xFFBBDEFB),
                    ],
                  ),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: supportTicket.messages.length,
                  itemBuilder: (context, index) {
                    final message = supportTicket.messages[index];
                    return ChatBubble(
                      message: message,
                      isUser: message.senderId != 'admin',
                    );
                  },
                ),
              ),
            ),
            _buildMessageInput(),
          ],
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 4.0,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.poppins(),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFF2196F3)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _showTicketInfo(BuildContext context, SupportTicket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ticket Information', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Ticket ID', ticket.id),
            _buildInfoRow('User ID', ticket.userId),
            _buildInfoRow('Status', ticket.status.toString().split('.').last),
            _buildInfoRow('Created', DateFormat('yyyy-MM-dd HH:mm').format(ticket.createdAt)),
            _buildInfoRow('Updated', DateFormat('yyyy-MM-dd HH:mm').format(ticket.updatedAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: GoogleFonts.poppins(color: Color(0xFF2196F3))),
          ),
          TextButton(
            onPressed: () => _showUpdateStatusDialog(context, ticket),
            child: Text('Update Status', style: GoogleFonts.poppins(color: Color(0xFF2196F3))),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          Text(value, style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, SupportTicket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Ticket Status', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: DropdownButton<TicketStatus>(
          value: ticket.status,
          items: TicketStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.toString().split('.').last, style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: (newStatus) {
            if (newStatus != null) {
              ref.read(supportProvider.notifier).updateTicketStatus(ticket.id, newStatus);
              Navigator.of(context).pop();
            }
          },
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}