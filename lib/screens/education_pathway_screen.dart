import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taleb_edu_platform/models/education_pathway.dart';
import 'package:taleb_edu_platform/providers/education_pathway_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:taleb_edu_platform/screens/specialization_details_screen.dart'; // Import for SpecializationDetailsScreen

class EducationPathwayScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathwaysAsyncValue = ref.watch(educationPathwayProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Education Pathways', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      ),
      body: pathwaysAsyncValue.when(
        data: (pathways) => _buildPathwayList(context, pathways),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildPathwayList(BuildContext context, List<EducationPathway> pathways) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: pathways.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildPathwayCard(context, pathways[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPathwayCard(BuildContext context, EducationPathway pathway) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecializationDetailsScreen(
                pathwayId: pathway.id, 
                specialization: pathway.specializations.first, // Assuming you want to show the first specialization
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: pathway.imageUrl.isNotEmpty
                    ? Image.network(
                        pathway.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
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
                      pathway.name,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    // Show number of specializations
                    Row(
                      children: [
                        Icon(Icons.list, size: 16, color: Theme.of(context).primaryColor),
                        SizedBox(width: 4),
                        Text(
                          '${pathway.specializations.length} Specialties',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
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
}
