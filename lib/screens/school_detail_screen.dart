// File: lib/screens/school_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:taleb_edu_platform/models/school_model.dart';

class SchoolDetailScreen extends StatelessWidget {
  final School school;

  const SchoolDetailScreen({Key? key, required this.school}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSchoolInfo(),
                  SizedBox(height: 24),
                  _buildSectionTitle('programs'.tr()),
                  _buildProgramsList(),
                  SizedBox(height: 24),
                  _buildSectionTitle('admission_requirements'.tr()),
                  _buildAdmissionRequirements(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(school.name),
        background: school.imageUrl != null
            ? Image.network(
                school.imageUrl!,
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey[300],
                child: Icon(Icons.school, size: 80, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildSchoolInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          school.name,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          school.description,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgramsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: school.programs.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.school),
          title: Text(
            school.programs[index],
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        );
      },
    );
  }

  Widget _buildAdmissionRequirements() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: school.admissionRequirements.length,
      itemBuilder: (context, index) {
        final requirement = school.admissionRequirements.entries.elementAt(index);
        return ListTile(
          leading: Icon(Icons.check_circle_outline),
          title: Text(
            requirement.key,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            requirement.value.toString(),
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        );
      },
    );
  }
}