import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:taleb_edu_platform/models/mostajadat_modal.dart';
import 'package:taleb_edu_platform/models/institution_model.dart';
import 'package:taleb_edu_platform/providers/mostajadat_provider.dart';
import 'package:taleb_edu_platform/screens/mostajadat_details_screen.dart';
import 'package:taleb_edu_platform/screens/admin_dashboard.dart';
import 'package:taleb_edu_platform/screens/institution_details_screen.dart';
import 'package:taleb_edu_platform/services/institution_service.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:taleb_edu_platform/models/education_pathway.dart';
import 'package:taleb_edu_platform/providers/education_pathway_provider.dart';

class MostajadatScreen extends ConsumerStatefulWidget {
  const MostajadatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MostajadatScreen> createState() => _MostajadatScreenState();
}

class _MostajadatScreenState extends ConsumerState<MostajadatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, String> categoryMap = {
    'institutions': 'institutions_label',
    'jobs': 'jobs_label',
    'guidance': 'guidance_label',
  };
  final List<String> _categories = [
    'institutions_label',
    'jobs_label',
    'guidance_label',
  ];
  String _searchQuery = '';

  List<Widget> _pathwayStack = [];
  EducationPathway? _selectedPathway;
  Specialization? _selectedSpecialization;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildCategoryTabs()),
        ],
        body: TabBarView(
          controller: _tabController,
          children: _categories.map((translationKey) {
            final category = categoryMap.keys.firstWhere(
                (key) => categoryMap[key] == translationKey);
            return _buildMostajadatList(category);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'logo',
                        child: Image.asset(
                          'assets/images/my.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tawjih',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.search,
                        color: Colors.black, size: 28),
                    onPressed: () => _showSearchDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _categories.asMap().entries.map((entry) {
                final index = entry.key;
                final translationKey = entry.value;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _tabController.index = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0),
                    child: _buildTab(index),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTab(int index) {
    final translationKey = _categories[index];
    final isSelected = _tabController.index == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        translationKey.tr(),
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildMostajadatList(String category) {
    if (category == 'guidance') {
      return _buildInstitutionsTab(context, ref);
    }

    if (category == 'institutions') {
      return ref.watch(mostajadatProvider).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (mostajadatList) {
          final filteredList = mostajadatList
              .where((mostajadat) =>
                  mostajadat.category == 'guidance' &&
                  (mostajadat.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      mostajadat.description.toLowerCase().contains(_searchQuery.toLowerCase())))
              .toList();

          return ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final mostajadat = filteredList[index];
              return MostajadatCard(
                mostajadat: mostajadat,
              );
            },
          );
        },
      );
    }


     return ref.watch(mostajadatProvider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (mostajadatList) {
        final filteredList = mostajadatList
            .where((mostajadat) =>
                mostajadat.category == category &&
                (mostajadat.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    mostajadat.description.toLowerCase().contains(_searchQuery.toLowerCase())))
            .toList();

        return ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final mostajadat = filteredList[index];
            return MostajadatCard(
              mostajadat: mostajadat,
            );
          },
        );
      },
    );
  }

  Widget _buildInstitutionsTab(BuildContext context, WidgetRef ref) {
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
            _pathwayStack = [_buildPathwaysView(context, ref, pathways)];
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
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildPathwaysView(BuildContext context, WidgetRef ref, List<EducationPathway> pathways) {
    final TextStyle cairoBold = GoogleFonts.cairo(fontWeight: FontWeight.bold);
    final TextStyle cairoSemiBold = GoogleFonts.cairo(fontWeight: FontWeight.w600);
    final TextStyle cairoRegular = GoogleFonts.cairo(fontWeight: FontWeight.normal);

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
                return AnimationConfiguration.staggeredList(                 position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildPathwayCard(context, ref, pathways[index]),
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

  Widget _buildPathwayCard(BuildContext context, WidgetRef ref, EducationPathway pathway) {
    final TextStyle cairoBold = GoogleFonts.cairo(fontWeight: FontWeight.bold);
    final TextStyle cairoSemiBold = GoogleFonts.cairo(fontWeight: FontWeight.w600);
    final TextStyle cairoRegular = GoogleFonts.cairo(fontWeight: FontWeight.normal);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPathway = pathway;
            _pathwayStack.add(_buildSpecializationsView(context, ref, pathway));
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

  Widget _buildSpecializationsView(BuildContext context, WidgetRef ref, EducationPathway pathway) {
    final TextStyle cairoBold = GoogleFonts.cairo(fontWeight: FontWeight.bold);
    final TextStyle cairoSemiBold = GoogleFonts.cairo(fontWeight: FontWeight.w600);
    final TextStyle cairoRegular = GoogleFonts.cairo(fontWeight: FontWeight.normal);
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
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration:                 const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildSpecializationCard(context, pathway.specializations[index]),
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

  Widget _buildSpecializationCard(BuildContext context, Specialization specialization) {
    final TextStyle cairoBold = GoogleFonts.cairo(fontWeight: FontWeight.bold);
    final TextStyle cairoSemiBold = GoogleFonts.cairo(fontWeight: FontWeight.w600);
    final TextStyle cairoRegular = GoogleFonts.cairo(fontWeight: FontWeight.normal);

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

  Widget _buildUniversitiesView(Specialization specialization) {
    final TextStyle cairoBold = GoogleFonts.cairo(fontWeight: FontWeight.bold);
    final TextStyle cairoSemiBold = GoogleFonts.cairo(fontWeight: FontWeight.w600);
    final TextStyle cairoRegular = GoogleFonts.cairo(fontWeight: FontWeight.normal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('الجامعات لتخصص ${specialization.name}'),
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
    final TextStyle cairoBold = GoogleFonts.cairo(fontWeight: FontWeight.bold);
    final TextStyle cairoSemiBold = GoogleFonts.cairo(fontWeight: FontWeight.w600);
    final TextStyle cairoRegular = GoogleFonts.cairo(fontWeight: FontWeight.normal);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // Handle university tap
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

  Widget _buildSectionHeader(String title) {
    final TextStyle cairoBold = GoogleFonts.cairo(fontWeight: FontWeight.bold);
    final TextStyle cairoSemiBold = GoogleFonts.cairo(fontWeight: FontWeight.w600);
    final TextStyle cairoRegular = GoogleFonts.cairo(fontWeight: FontWeight.normal);
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

  void _showEditMostajadatDialog(BuildContext context, Mostajadat mostajadat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminDashboardScreen(),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('search'.tr(), style: GoogleFonts.cairo()),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'enter_search_term'.tr(),
            hintStyle: GoogleFonts.cairo(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            child: Text('cancel'.tr(), style: GoogleFonts.cairo()),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('search'.tr(), style: GoogleFonts.cairo()),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}


class MostajadatCard extends StatelessWidget {
  final Mostajadat mostajadat;

  const MostajadatCard({Key? key, required this.mostajadat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedDeadlineDate = mostajadat.deadlineDate != null
        ? dateFormat.format(mostajadat.deadlineDate!)
        : 'غير محدد';

    Color getHeaderColor(String type) {
      switch (type.toLowerCase()) {
        case 'بكالوريا':
          return Colors.orange;
        case 'بكالوريا+1':
          return Colors.blue[700]!;
        case 'بكالوريا+2':
          return Colors.green[600]!;
        case 'بكالوريا+3':
          return Colors.purple[600]!;
        case 'بكالوريا+4':
          return Colors.red[600]!;
        case 'بكالوريا+5':
          return Colors.teal[600]!;
        case 'أخرى':
          return Colors.grey[600]!;
        default:
          return Colors.grey[600]!;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MostajadatDetailsScreen(mostajadat: mostajadat),
          ),
        );
      },
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(35.0),
                      child: Image.network(
                        mostajadat.cardImagePath ?? mostajadat.imageUrl, // Use cardImagePath if available
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: mostajadat.type == 'دوني'
                            ? Colors.red
                            : Colors.blue,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        mostajadat.type,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  mostajadat.title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          'deadline'.tr() +
                              ': $formattedDeadlineDate',
                          style: GoogleFonts.cairo(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MostajadatDetailsScreen(
                                mostajadat: mostajadat),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        textStyle: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('details'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


extension ListExtension<T> on List<T> {
  T? get lastOrNull => isNotEmpty ? last : null;
}