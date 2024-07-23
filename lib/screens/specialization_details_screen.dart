import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taleb_edu_platform/models/education_pathway.dart';
import 'package:taleb_edu_platform/providers/education_pathway_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:taleb_edu_platform/screens/guidance_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SpecializationDetailsScreen extends ConsumerWidget {
  final String pathwayId;
  final Specialization specialization;

  const SpecializationDetailsScreen({
    Key? key,
    required this.pathwayId,
    required this.specialization,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathwaysAsyncValue = ref.watch(educationPathwayProvider);

    final TextStyle cairoBold = GoogleFonts.cairo(fontWeight: FontWeight.bold);
    final TextStyle cairoSemiBold = GoogleFonts.cairo(fontWeight: FontWeight.w600);
    final TextStyle cairoRegular = GoogleFonts.cairo(fontWeight: FontWeight.normal);

    return Scaffold(
      appBar: AppBar(
        title: Text(specialization.name, style: cairoBold.copyWith(fontSize: 18)),
      ),
      body: pathwaysAsyncValue.when(
        data: (pathways) {
          final selectedPathway = pathways.firstWhere((p) => p.id == pathwayId);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Specialization details
              Container(
                padding: EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialization.name,
                      style: cairoSemiBold.copyWith(fontSize: 24, color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(height: 8),
                    Text(
                      specialization.description,
                      style: cairoRegular.copyWith(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.school, color: Theme.of(context).primaryColor),
                        SizedBox(width: 8),
                        Text(
                          '${specialization.universities.length} Universities',
                          style: cairoSemiBold.copyWith(fontSize: 16, color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Universities offering ${specialization.name}',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Display Universities for this Specialization
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: specialization.universities.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildUniversityCard(context, specialization.universities[index], cairoSemiBold, cairoRegular),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Other Specializations in ${selectedPathway.name}',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Display other Specializations within this Pathway
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: selectedPathway.specializations.length,
                    itemBuilder: (context, index) {
                      final otherSpecialization = selectedPathway.specializations[index];
                      if (otherSpecialization.id != specialization.id) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: ListTile(
                                title: Text(otherSpecialization.name),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SpecializationDetailsScreen(
                                        pathwayId: selectedPathway.id,
                                        specialization: otherSpecialization,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox.shrink(); // Don't show the current specialization
                      }
                    },
                  ),
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

  Widget _buildUniversityCard(BuildContext context, University university, TextStyle cairoSemiBold, TextStyle cairoRegular) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UniversityDetailsScreen(university: university),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: university.imageUrl.isNotEmpty
                  ? Image.network(
                university.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              )
                  : Container(
                height: 150,
                color: Colors.grey[300],
                child: Icon(Icons.school, size: 50, color: Colors.grey[600]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    university.name,
                    style: cairoSemiBold.copyWith(fontSize: 18, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Text(
                    university.description,
                    style: cairoRegular.copyWith(fontSize: 14, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.link, size: 16, color: Theme.of(context).primaryColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          university.website,
                          style: cairoRegular.copyWith(fontSize: 14, color: Theme.of(context).primaryColor),
                          maxLines: 1,
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
    );
  }

  void _showUniversityDetails(BuildContext context, University university, TextStyle cairoSemiBold, TextStyle cairoRegular) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(university.name, style: cairoSemiBold),
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
              Text('Website:', style: cairoSemiBold),
              InkWell(
                onTap: () => _launchURL(context, university.website),
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
            child: Text('Close', style: cairoRegular),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _launchURL(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url', style: GoogleFonts.cairo())),
      );
    }
  }
}