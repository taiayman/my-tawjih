// File: lib/screens/announcements_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:taleb_edu_platform/models/announcement_model.dart';
import 'package:taleb_edu_platform/providers/announcement_provider.dart';
import 'package:taleb_edu_platform/providers/data_providers.dart';
import 'package:taleb_edu_platform/widgets/announcement_card.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  @override
  _AnnouncementsScreenState createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'bac', 'bac+2', 'bac+3', 'other'];

  @override
  Widget build(BuildContext context) {
    final announcements = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('announcements'.tr()),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: announcements.when(
              data: (announcements) {
                final filteredAnnouncements = _filterAnnouncements(announcements);
                return filteredAnnouncements.isEmpty
                    ? Center(child: Text('no_announcements'.tr()))
                    : ListView.builder(
                        itemCount: filteredAnnouncements.length,
                        itemBuilder: (context, index) {
                          return AnnouncementCard(announcement: filteredAnnouncements[index]);
                        },
                      );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('error_loading_announcements'.tr())),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement search functionality
        },
        child: Icon(Icons.search),
        tooltip: 'search_announcements'.tr(),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: _filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter.tr()),
              selected: _selectedFilter == filter,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'all';
                });
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Announcement> _filterAnnouncements(List<Announcement> announcements) {
    if (_selectedFilter == 'all') {
      return announcements;
    }
    return announcements.where((announcement) => announcement.category == _selectedFilter).toList();
  }
}

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementCard({Key? key, required this.announcement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to announcement details
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCategoryChip(context),
                  Spacer(),
                  Text(
                    DateFormat('MMM d, yyyy').format(announcement.date),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                announcement.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                announcement.description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.school, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    announcement.schoolName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    return Chip(
      label: Text(
        announcement.category.tr(),
        style: GoogleFonts.poppins(fontSize: 12),
      ),
      backgroundColor: _getCategoryColor(announcement.category),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'bac':
        return Colors.blue[100]!;
      case 'bac+2':
        return Colors.green[100]!;
      case 'bac+3':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}