import 'package:flutter/material.dart';
import 'package:taleb_edu_platform/models/support_ticket.dart';

class StatusBadge extends StatelessWidget {
  final TicketStatus status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case TicketStatus.open:
        color = Colors.green;
        text = 'Open';
        break;
      case TicketStatus.inProgress:
        color = Colors.orange;
        text = 'In Progress';
        break;
      case TicketStatus.resolved:
        color = Colors.blue;
        text = 'Resolved';
        break;
      case TicketStatus.closed:
        color = Colors.red;
        text = 'Closed';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
