import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taleb_edu_platform/models/guidance_category_model.dart';

class GuidanceItemScreen extends StatelessWidget {
  final GuidanceItem item;

  const GuidanceItemScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.name,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageUrl != null)
                Image.network(
                  item.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 16),
              Text(
                item.name,
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                item.description,
                style: GoogleFonts.cairo(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}