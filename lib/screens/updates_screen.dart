import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taleb_edu_platform/models/announcement_model.dart';
import 'package:taleb_edu_platform/providers/announcement_provider.dart';
import 'package:taleb_edu_platform/widgets/announcement_list_item.dart';
import 'package:taleb_edu_platform/screens/announcement_details_screen.dart';

class UpdatesScreen extends ConsumerStatefulWidget {
  @override
  _UpdatesScreenState createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends ConsumerState<UpdatesScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreAnnouncements();
    }
  }

  Future<void> _loadMoreAnnouncements() async {
    if (!_isLoading) {
      setState(() => _isLoading = true);
      await ref.read(announcementNotifierProvider.notifier).loadMore();
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsyncValue = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Updates',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(announcementNotifierProvider);
          await ref.read(announcementNotifierProvider.notifier).loadInitial(); 
        },
        child: announcementsAsyncValue.when(
          data: (announcements) => ListView.builder(
            controller: _scrollController,
            itemCount: announcements.length + 1,
            itemBuilder: (context, index) {
              if (index < announcements.length) {
                return AnnouncementListItem(
                  announcement: announcements[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementDetailsScreen(announcement: announcements[index]),
                    ),
                  ),
                );
              } else if (_isLoading) {
                return Center(child: CircularProgressIndicator());
              } else {
                return SizedBox.shrink();
              }
            },
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
