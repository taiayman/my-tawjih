import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taleb_edu_platform/models/announcement_model.dart';
import 'package:taleb_edu_platform/providers/job_competitions_provider.dart';
import 'package:taleb_edu_platform/widgets/announcement_list_item.dart';
import 'package:taleb_edu_platform/screens/announcement_details_screen.dart';

class JobCompetitionsScreen extends ConsumerStatefulWidget {
  @override
  _JobCompetitionsScreenState createState() => _JobCompetitionsScreenState();
}

class _JobCompetitionsScreenState extends ConsumerState<JobCompetitionsScreen> {
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
      _loadMoreJobCompetitions();
    }
  }

  Future<void> _loadMoreJobCompetitions() async {
    if (!_isLoading) {
      setState(() => _isLoading = true);
      await ref.read(jobCompetitionsNotifierProvider.notifier).loadMore();
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobCompetitionsAsyncValue = ref.watch(jobCompetitionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jobs & Competitions',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(jobCompetitionsNotifierProvider);
          await ref.read(jobCompetitionsNotifierProvider.notifier).loadInitial(); 
        },
        child: jobCompetitionsAsyncValue.when(
          data: (jobCompetitions) => ListView.builder(
            controller: _scrollController,
            itemCount: jobCompetitions.length + 1,
            itemBuilder: (context, index) {
              if (index < jobCompetitions.length) {
                return AnnouncementListItem(
                  announcement: jobCompetitions[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementDetailsScreen(announcement: jobCompetitions[index]),
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
