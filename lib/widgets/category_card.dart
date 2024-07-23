// File: lib/widgets/category_grid.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'bac', 'icon': Icons.school},
    {'name': 'bac+2', 'icon': Icons.business},
    {'name': 'bac+3', 'icon': Icons.architecture},
    {'name': 'other', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(context, categories[index]);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to category-specific screen
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category['icon'],
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 8),
              Text(
                category['name'].tr(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}