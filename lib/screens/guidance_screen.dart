import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taleb_edu_platform/models/education_pathway.dart';
import 'package:taleb_edu_platform/providers/education_pathway_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:taleb_edu_platform/screens/web_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';


class GuidanceScreen extends ConsumerStatefulWidget {
  @override
  _GuidanceScreenState createState() => _GuidanceScreenState();
}

class _GuidanceScreenState extends ConsumerState<GuidanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Widget> _pathwayStack = [];
  EducationPathway? _selectedPathway;
  Specialization? _selectedSpecialization;
  final TextEditingController _searchController = TextEditingController();
  List<University> _searchResults = [];
  bool _isSearching = false;
  
  final TextStyle cairoBold = GoogleFonts.cairo(fontWeight: FontWeight.bold);
  final TextStyle cairoSemiBold = GoogleFonts.cairo(fontWeight: FontWeight.w600);
  final TextStyle cairoRegular = GoogleFonts.cairo(fontWeight: FontWeight.normal);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التوجيه التعليمي', style: cairoBold.copyWith(fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: cairoBold.copyWith(fontSize: 14),
          tabs: [
            Tab(icon: Icon(Icons.school), text: 'المسارات'),
            Tab(icon: Icon(Icons.business), text: 'المؤسسات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPathwaysTab(),
          _buildAllUniversitiesTab(),
        ],
      ),
    );
  }

  Widget _buildPathwaysTab() {
    final pathwaysAsyncValue = ref.watch(educationPathwayProvider);

    return WillPopScope(
      onWillPop: () async {
        if (_pathwayStack.length > 1) {
          setState(() {
            _pathwayStack.removeLast();
            if (_pathwayStack.length == 1) {
              _selectedPathway = null;
              _selectedSpecialization = null;
            } else if (_pathwayStack.length == 2) {
              _selectedSpecialization = null;
            }
          });
          return false;
        }
        return true;
      },
      child: pathwaysAsyncValue.when(
        data: (pathways) {
          if (_pathwayStack.isEmpty) {
            _pathwayStack = [_buildPathwaysView(pathways)];
          }
          return Stack(
            children: [
              _pathwayStack.lastOrNull ?? Container(),
              if (_pathwayStack.length > 1)
                Positioned(
                  top: 16,
                  left: 16,
                  child: FloatingActionButton(
                    mini: true,
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _pathwayStack.removeLast();
                        if (_pathwayStack.length == 1) {
                          _selectedPathway = null;
                          _selectedSpecialization = null;
                        } else if (_pathwayStack.length == 2) {
                          _selectedSpecialization = null;
                        }
                      });
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطأ: $error')),
      ),
    );
  }

  Widget _buildPathwaysView(List<EducationPathway> pathways) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('المسارات التعليمية'),
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: pathways.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildPathwayCard(pathways[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPathwayCard(EducationPathway pathway) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPathway = pathway;
            _pathwayStack.add(_buildSpecializationsView(pathway));
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pathway.name,
                style: cairoSemiBold.copyWith(fontSize: 20, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                pathway.description,
                style: cairoRegular.copyWith(fontSize: 14, color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.library_books, color: Colors.blue.shade600),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${pathway.specializations.length} تخصصات',
                      style: cairoSemiBold.copyWith(fontSize: 14, color: Colors.blue.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

Widget _buildSpecializationsView(EducationPathway pathway) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _buildSectionHeader('تخصصات ${pathway.name}'),
      Expanded(
        child: AnimationLimiter(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: pathway.specializations.length,
            itemBuilder: (context, index) {
              final specialization = pathway.specializations[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Column(
                      children: [
                        _buildSpecializationCard(specialization),
                        SizedBox(height: 8),
                        FadeInConnectionLine(height: 40),
                        SizedBox(height: 8),
                        _buildUniversitiesSection(specialization),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}


Widget _buildUniversitiesSection(Specialization specialization) {
  return Card(
    elevation: 2,
    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            AnimationLimiter(
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  childAspectRatio: 0.7, // Adjusted to account for the taller cards
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
),
              itemCount: specialization.universities.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _buildEnhancedUniversityCard(specialization.universities[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildEnhancedUniversityCard(University university) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    color: Colors.white,
    child: Container(
      height: 350, // Increased height to 350 logical pixels
      width: 200,  // Added a fixed width to make the card larger
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UniversityDetailsScreen(university: university),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5, // Increased flex for the image area
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: university.imageUrl.isNotEmpty
                    ? Image.network(
                        university.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.school, size: 60, color: Colors.grey[600]),
                      ),
              ),
            ),
            Expanded(
              flex: 4, // Increased flex for the text area
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      university.name,
                      style: cairoSemiBold.copyWith(fontSize: 20, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8), // Added space between name and link
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.link, size: 20, color: Colors.blue.shade600),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  university.website,
                                  style: cairoRegular.copyWith(fontSize: 14, color: Colors.blue.shade600),
                                  maxLines: 2, // Increased to 2 lines
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSpecializationCard(Specialization specialization) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSpecialization = specialization;
            _pathwayStack.add(_buildUniversitiesView(specialization));
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                specialization.name,
                style: cairoSemiBold.copyWith(fontSize: 18, color: Colors.black87),
              ),
              SizedBox(height: 8),
              Text(
                specialization.description,
                style: cairoRegular.copyWith(fontSize: 14, color: Colors.black54),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.school, color: Colors.green.shade600),
                  SizedBox(width: 8),
                  Text(
                    '${specialization.universities.length} جامعات',
                    style: cairoSemiBold.copyWith(fontSize: 14, color: Colors.green.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlexibleHeader(String title) {
    return Container(
      padding: EdgeInsets.fromLTRB(60, 24, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: cairoBold.copyWith(
                fontSize: 20,
                color: Colors.blue.shade800,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversitiesView(Specialization specialization) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFlexibleHeader('الجامعات لتخصص ${specialization.name}'),
        Expanded(
          child: AnimationLimiter(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: specialization.universities.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _buildUniversityCard(specialization.universities[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUniversityCard(University university) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UniversityDetailsScreen(university: university),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: university.imageUrl.isNotEmpty
                    ? Image.network(
                        university.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.school, size: 50, color: Colors.grey[600]),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      university.name,
                      style: cairoSemiBold.copyWith(fontSize: 16, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Icon(Icons.link, size: 16, color: Colors.blue.shade600),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            university.website,
                            style: cairoRegular.copyWith(fontSize: 12, color: Colors.blue.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllUniversitiesTab() {
    final pathwaysAsyncValue = ref.watch(educationPathwayProvider);

    return pathwaysAsyncValue.when(
      data: (pathways) {
        List<University> allUniversities = [];
        for (var pathway in pathways) {
          for (var specialization in pathway.specializations) {
            allUniversities.addAll(specialization.universities);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('جميع الجامعات'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
  controller: _searchController,
  style: cairoRegular.copyWith(fontSize: 16, color: Colors.black), // Changed text color to black
  decoration: InputDecoration(
    hintText: 'ابحث عن الجامعات...',
    hintStyle: cairoRegular.copyWith(fontSize: 16, color: Colors.grey),
    prefixIcon: Icon(Icons.search, color: Colors.blue),
    border: InputBorder.none,
    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
  ),
  onChanged: (value) => _performSearch(value, allUniversities),
),
              ),
            ),
            Expanded(
              child: AnimationLimiter(
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _isSearching ? _searchResults.length : allUniversities.length,
                  itemBuilder: (context, index) {
                    final university = _isSearching ? _searchResults[index] : allUniversities[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: _buildUniversityCard(university),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('خطأ: $error')),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: cairoBold.copyWith(
          fontSize: 24,
          color: Colors.blue.shade800,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  void _performSearch(String query, List<University> allUniversities) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
        _isSearching = false;
      } else {
        _searchResults = allUniversities
            .where((university) =>
                university.name.toLowerCase().contains(query.toLowerCase()) ||
                university.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _isSearching = true;
      }
    });
  }
}

extension ListExtension<T> on List<T> {
  T? get lastOrNull => isNotEmpty ? last : null;
}


class UniversityDetailsScreen extends StatefulWidget {
  final University university;

  const UniversityDetailsScreen({Key? key, required this.university}) : super(key: key);

  @override
  _UniversityDetailsScreenState createState() => _UniversityDetailsScreenState();
}

class _UniversityDetailsScreenState extends State<UniversityDetailsScreen> {
  late ScrollController _scrollController;
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 400) {
            _showBackToTopButton = true;
          } else {
            _showBackToTopButton = false;
          }
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    _buildNameCard(),
                    _buildWebsiteCard(context),
                    _buildDescriptionCard(),
                    _buildContentSection(),
                    _buildDownloadCard(context),
                    _buildShareCard(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              child: Icon(Icons.arrow_upward),
              tooltip: 'العودة إلى الأعلى',
            )
          : null,
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final top = constraints.biggest.height;
          final expandRatio = (top - kToolbarHeight) / (200.0 - kToolbarHeight);
          final isCollapsed = expandRatio <= 0.5;

          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedOpacity(
                opacity: isCollapsed ? 0.0 : 1.0,
                duration: Duration(milliseconds: 300),
                child: Hero(
                  tag: 'university-image-${widget.university.id}',
                  child: widget.university.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.university.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.school, size: 80, color: Colors.white),
                        ),
                ),
              ),
              Positioned(
                left: 16,
                top: MediaQuery.of(context).padding.top + 8,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCollapsed ? Color(0xFFFFFFFF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildNameCard() {
    return Card(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          widget.university.name,
          style: GoogleFonts.cairo(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildWebsiteCard(BuildContext context) {
    return Card(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _launchURL(context, widget.university.website),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.language, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'زيارة الموقع الإلكتروني',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            _buildFormattedDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedDescription() {
    final List<Widget> descriptionWidgets = [];
    final paragraphs = widget.university.description.split('\n');

    for (final paragraph in paragraphs) {
      if (paragraph.trim().startsWith('-')) {
        final endIndex = paragraph.indexOf('.', paragraph.indexOf('-'));
        if (endIndex != -1) {
          final bulletPoint = paragraph.substring(0, endIndex + 1);
          descriptionWidgets.add(
            Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildHighlightedText(bulletPoint),
            ),
          );
          if (endIndex + 1 < paragraph.length) {
            descriptionWidgets.add(_buildHighlightedText(paragraph.substring(endIndex + 1)));
          }
        } else {
          descriptionWidgets.add(
            Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildHighlightedText(paragraph),
            ),
          );
        }
      } else {
        descriptionWidgets.add(_buildHighlightedText(paragraph));
      }
      descriptionWidgets.add(SizedBox(height: 8));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: descriptionWidgets,
    );
  }

  Widget _buildHighlightedText(String text) {
    final List<InlineSpan> spans = [];
    final RegExp regExp = RegExp(r'\(([^)]+)\)');
    int lastMatchEnd = 0;

    for (final Match match in regExp.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      spans.add(
        WidgetSpan(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.lightGreen.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              match.group(1)!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16, color: Colors.black),
        children: spans,
      ),
    );
  }

  Widget _buildContentSection() {
    return SizedBox.shrink();
  }

  Widget _buildDownloadCard(BuildContext context) {
    return Card(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _downloadPdf(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text(
                'تحميل كملف PDF',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareCard(BuildContext context) {
    return Card(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _shareContent(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text(
                'مشاركة المحتوى',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(BuildContext context, String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url),
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(widget.university.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('الموقع الإلكتروني: ${widget.university.website}'),
              pw.SizedBox(height: 20),
              pw.Text('وصف الجامعة:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(widget.university.description),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/university_${widget.university.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحميل الملف بنجاح')),
    );

    if (await canLaunch(file.path)) {
      await launch(file.path);
    } else {
      print('Could not launch ${file.path}');
    }
  }

  void _shareContent(BuildContext context) {
    final String content = '''
${widget.university.name}

الموقع الإلكتروني: ${widget.university.website}

وصف الجامعة:
${widget.university.description}
''';

    Share.share(content, subject: widget.university.name);
  }
}


class FadeInConnectionLine extends StatefulWidget {
  final double height;

  const FadeInConnectionLine({Key? key, required this.height}) : super(key: key);

  @override
  _FadeInConnectionLineState createState() => _FadeInConnectionLineState();
}

class _FadeInConnectionLineState extends State<FadeInConnectionLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomPaint(
        size: Size(double.infinity, widget.height),
        painter: ConnectionLinePainter(),
      ),
    );
  }
}

class ConnectionLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height * 0.6);
    path.lineTo(size.width * 0.25, size.height);
    path.moveTo(size.width / 2, size.height * 0.6);
    path.lineTo(size.width * 0.75, size.height);

    canvas.drawPath(path, paint);

    final circlePaint = Paint()
      ..color = Colors.blue.shade500
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.25, size.height), 3, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height), 3, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}