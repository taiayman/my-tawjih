import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taleb_edu_platform/models/education_pathway.dart';
import 'package:taleb_edu_platform/providers/education_pathway_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationPathwayDetailsScreen extends ConsumerStatefulWidget {
  final EducationPathway pathway;

  const EducationPathwayDetailsScreen({Key? key, required this.pathway}) : super(key: key);

  @override
  _EducationPathwayDetailsScreenState createState() => _EducationPathwayDetailsScreenState();
}

class _EducationPathwayDetailsScreenState extends ConsumerState<EducationPathwayDetailsScreen> {
  List<Widget> _contentStack = [];
  Specialization? _selectedSpecialization;

  final TextStyle cairoBold = GoogleFonts.cairo(fontWeight: FontWeight.bold);
  final TextStyle cairoSemiBold = GoogleFonts.cairo(fontWeight: FontWeight.w600);
  final TextStyle cairoRegular = GoogleFonts.cairo(fontWeight: FontWeight.normal);

  @override
  void initState() {
    super.initState();
    _contentStack = [_buildSpecializationsView()];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_contentStack.length > 1) {
          setState(() {
            _contentStack.removeLast();
            if (_contentStack.length == 1) {
              _selectedSpecialization = null;
            }
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.pathway.name, style: cairoBold.copyWith(fontSize: 18)),
        ),
        body: Stack(
          children: [
            _contentStack.last,
            if (_contentStack.length > 1)
              Positioned(
                top: 16,
                left: 16,
                child: FloatingActionButton(
                  mini: true,
                  child: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _contentStack.removeLast();
                      if (_contentStack.length == 1) {
                        _selectedSpecialization = null;
                      }
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializationsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('تخصصات ${widget.pathway.name}'),
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.pathway.specializations.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildSpecializationCard(widget.pathway.specializations[index]),
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

  Widget _buildSpecializationCard(Specialization specialization) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSpecialization = specialization;
            _contentStack.add(_buildUniversitiesView(specialization));
          });
        },
        borderRadius: BorderRadius.circular(15),
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
                  Icon(Icons.school, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    '${specialization.universities.length} جامعات',
                    style: cairoSemiBold.copyWith(fontSize: 14, color: Theme.of(context).primaryColor),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showUniversityDetails(university),
        borderRadius: BorderRadius.circular(15),
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
                        Icon(Icons.link, size: 16, color: Theme.of(context).primaryColor),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            university.website,
                            style: cairoRegular.copyWith(fontSize: 12, color: Theme.of(context).primaryColor),
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
    return Container(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: cairoBold.copyWith(
          fontSize: 24,
          color: Theme.of(context).primaryColor,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  void _showUniversityDetails(University university) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(university.name, style: cairoBold),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (university.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    university.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 16),
              Text(university.description, style: cairoRegular),
              SizedBox(height: 16),
              Text('الموقع الإلكتروني:', style: cairoSemiBold),
              InkWell(
                onTap: () => _launchURL(university.website),
                child: Text(
                  university.website,
                  style: cairoRegular.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('إغلاق', style: cairoRegular),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا يمكن فتح الرابط', style: cairoRegular)),
      );
    }
  }
}