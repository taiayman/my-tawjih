import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taleb_edu_platform/models/guidance_category_model.dart';
import 'package:taleb_edu_platform/screens/guidance_item_screen.dart';

class SubcategoryScreen extends StatelessWidget {
  final GuidanceCategory category;

  const SubcategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.name,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: category.subcategories.length,
        itemBuilder: (context, index) {
          final subcategory = category.subcategories[index];
          return ExpansionTile(
            title: Text(
              subcategory.name,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            children: subcategory.items.map((item) {
              return ListTile(
                title: Text(
                  item.name,
                  style: GoogleFonts.cairo(),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuidanceItemScreen(item: item),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}