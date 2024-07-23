import 'package:flutter/material.dart';
import 'package:taleb_edu_platform/models/support_ticket.dart';

class TicketListItem extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const TicketListItem({
    Key? key,
    required this.ticket,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Ticket #${ticket.id}'),
      subtitle: Text('Status: ${ticket.status.toString().split('.').last}'),
      trailing: Text(ticket.updatedAt.toString()),
      onTap: onTap,
    );
  }
}
