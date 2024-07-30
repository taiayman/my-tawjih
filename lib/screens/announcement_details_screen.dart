import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:taleb_edu_platform/models/announcement_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementDetailsScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailsScreen({Key? key, required this.announcement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل الإعلان',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    DateFormat('dd/MM/yyyy').format(announcement.date),
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    announcement.fullText,
                    style: GoogleFonts.cairo(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  _buildDownloadButton(),
                  SizedBox(height: 16),
                  _buildRegistrationButton(),
                  SizedBox(height: 24),
                  _buildApplicationDetails(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(announcement.schoolImageUrl ?? ''),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcement.schoolName,
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              _buildEducationLevelChip(announcement.category),
            ],
          ),
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        if (announcement.officialDocumentUrl != null) {
          if (await canLaunch(announcement.officialDocumentUrl!)) {
            await launch(announcement.officialDocumentUrl!);
          }
        }
      },
      icon: Icon(Icons.file_download),
      label: Text(
        'تحميل الإعلان الرسمي',
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.blue,
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildRegistrationButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        if (announcement.registrationLink != null) {
          if (await canLaunch(announcement.registrationLink!)) {
            await launch(announcement.registrationLink!);
          }
        }
      },
      icon: Icon(Icons.app_registration),
      label: Text(
        'التسجيل',
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.green,
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildApplicationDetails() {
    if (announcement.applicationDetails == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفاصيل التقديم',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...announcement.applicationDetails!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}:',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: GoogleFonts.cairo(),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}