import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:taleb_edu_platform/models/announcement_model.dart';

class AnnouncementListItem extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const AnnouncementListItem({
    Key? key,
    required this.announcement,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(announcement.schoolImageUrl ?? ''),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(announcement.date),
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 8),
                      _buildEducationLevelChip(announcement.category),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationLevelChip(String category) {
    Color chipColor;
    String label;
    switch (category) {
      case 'bac':
        chipColor = Colors.green;
        label = 'باك';
        break;
      case 'bac+2':
        chipColor = Colors.blue;
        label = 'باك+2';
        break;
      default:
        chipColor = Colors.orange;
        label = category;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        border: Border.all(color: chipColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }
}