import 'package:flutter/material.dart';
   import 'package:taleb_edu_platform/models/institution_model.dart';

   class FacultyDetailsScreen extends StatelessWidget {
     final String institutionId;
     final String categoryId;
     final Faculty faculty;

     FacultyDetailsScreen({
       required this.institutionId,
       required this.categoryId,
       required this.faculty,
     });

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: Text(faculty.name)),
         body: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 'Name: ${faculty.name}',
                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
               ),
               SizedBox(height: 16),
               Text(
                 'Description: ${faculty.description}',
                 style: TextStyle(fontSize: 16),
               ),
             ],
           ),
         ),
       );
     }
   }
