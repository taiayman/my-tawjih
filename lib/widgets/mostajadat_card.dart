import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:taleb_edu_platform/models/mostajadat_modal.dart';

Widget buildMostajadatCard(Mostajadat mostajadat) {
  final dateFormat = DateFormat('dd/MM/yyyy');
  final formattedDeadlineDate = mostajadat.deadlineDate != null
      ? dateFormat.format(mostajadat.deadlineDate!)
      : 'غير محدد';

  Color getHeaderColor(String type) {
    switch (type.toLowerCase()) {
      case 'باك':
        return Colors.orange;
      case 'باك+1':
        return Colors.blue[700]!;
      case 'باك+2':
        return Colors.green[600]!;
      case 'باك+3':
        return Colors.purple[600]!;
      case 'باك+4':
        return Colors.red[600]!;
      case 'باك+5':
        return Colors.teal[600]!;
      case 'أخرى':
        return Colors.grey[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: getHeaderColor(mostajadat.type),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(mostajadat.imageUrl),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mostajadat.title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      mostajadat.type,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'اخر أجل: $formattedDeadlineDate',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle button press
                  },
                  child: Text(
                    'التفاصيل',
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getHeaderColor(mostajadat.type),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}