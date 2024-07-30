import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taleb_edu_platform/models/education_pathway.dart';
import 'package:taleb_edu_platform/providers/education_pathway_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:taleb_edu_platform/screens/guidance_screen.dart';
import 'dart:io';

import 'package:taleb_edu_platform/screens/university_customization_screen.dart';

class AdminEducationPathwayScreen extends ConsumerStatefulWidget {
  @override
  _AdminEducationPathwayScreenState createState() => _AdminEducationPathwayScreenState();
}

class _AdminEducationPathwayScreenState extends ConsumerState<AdminEducationPathwayScreen> with SingleTickerProviderStateMixin {
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
        title: Text('إدارة المسارات التعليمية', style: cairoBold.copyWith(fontSize: 18)),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: Icon(Icons.add),
        label: Text('إضافة', style: cairoSemiBold),
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
              _pathwayStack.isNotEmpty ? _pathwayStack.last : Container(),
if (_pathwayStack.length > 1)
  Positioned(
    top: 5, // This will push it up into the status bar area
    left: 16,
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
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
            child: SizedBox(
              width: 34,
              height: 34,
              child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pathway.name,
                    style: cairoSemiBold.copyWith(fontSize: 20, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editPathway(pathway),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePathway(pathway.id),
                    ),
                  ],
                ),
              ],
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
                Text(
                  '${pathway.specializations.length} تخصصات',
                  style: cairoSemiBold.copyWith(fontSize: 14, color: Colors.blue.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _editPathway(EducationPathway pathway) {
  final _formKey = GlobalKey<FormState>();
  String _name = pathway.name;
  String _description = pathway.description;
  String _imageUrl = pathway.imageUrl;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('تعديل المسار التعليمي', style: cairoBold),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'اسم المسار',
                  labelStyle: cairoRegular,
                ),
                style: TextStyle(color: Colors.black),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم المسار' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  labelStyle: cairoRegular,
                ),
                style: TextStyle(color: Colors.black),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال وصف المسار' : null,
                onSaved: (value) => _description = value!,
              ),
              
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('إلغاء', style: cairoRegular),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('حفظ التغييرات', style: cairoSemiBold),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final updatedPathway = EducationPathway(
                id: pathway.id,
                name: _name,
                description: _description,
                imageUrl: _imageUrl,
                specializations: pathway.specializations,
              );
              await ref.read(educationPathwayProvider.notifier).updatePathway(updatedPathway);
              Navigator.of(context).pop();
              setState(() {}); // Refresh the UI
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تحديث المسار التعليمي بنجاح', style: cairoRegular))
              );
            }
          },
        ),
      ],
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
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildSpecializationCard(pathway.specializations[index]),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    specialization.name,
                    style: cairoSemiBold.copyWith(fontSize: 18, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editSpecialization(specialization),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteSpecialization(specialization.id),
                    ),
                  ],
                ),
              ],
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

void _editSpecialization(Specialization specialization) {
  final _formKey = GlobalKey<FormState>();
  String _name = specialization.name;
  String _description = specialization.description;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('تعديل التخصص', style: cairoBold),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'اسم التخصص',
                  labelStyle: cairoRegular.copyWith(color: Colors.black54),
                ),
                style: TextStyle(color: Colors.black), // Set text color to black
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم التخصص' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  labelStyle: cairoRegular.copyWith(color: Colors.black54),
                ),
                style: TextStyle(color: Colors.black), // Set text color to black
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال وصف التخصص' : null,
                onSaved: (value) => _description = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('إلغاء', style: cairoRegular),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('حفظ التغييرات', style: cairoSemiBold),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final updatedSpecialization = Specialization(
                id: specialization.id,
                name: _name,
                description: _description,
                universities: specialization.universities,
              );
              int specializationIndex = _selectedPathway!.specializations.indexWhere((s) => s.id == specialization.id);
              _selectedPathway!.specializations[specializationIndex] = updatedSpecialization;
              ref.read(educationPathwayProvider.notifier).updatePathway(_selectedPathway!);
              Navigator.of(context).pop();
              setState(() {}); // Refresh the UI
            }
          },
        ),
      ],
    ),
  );
}

void _deleteSpecialization(String specializationId) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('تأكيد الحذف', style: cairoBold),
      content: Text('هل أنت متأكد من حذف هذا التخصص؟', style: cairoRegular),
      actions: [
        TextButton(
          child: Text('إلغاء', style: cairoRegular),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text('حذف', style: cairoRegular.copyWith(color: Colors.red)),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  if (result == true) {
    _selectedPathway!.specializations.removeWhere((spec) => spec.id == specializationId);
    await ref.read(educationPathwayProvider.notifier).updatePathway(_selectedPathway!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حذف التخصص', style: cairoRegular))
    );
    setState(() {}); // Refresh the UI
  }
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
    margin: EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: university.imageUrl.isNotEmpty
                  ? Image.network(
                      university.imageUrl,
                      height: 110,
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
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  _buildIconButton(
                    icon: Icons.edit,
                    color: Colors.blue,
                    onPressed: () => _editUniversity(university),
                  ),
                  SizedBox(width: 8),
                  _buildIconButton(
                    icon: Icons.delete,
                    color: Colors.red,
                    onPressed: () => _deleteUniversity(university),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                university.name,
                style: cairoSemiBold.copyWith(fontSize: 18, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildIconButton({
  required IconData icon,
  required Color color,
  required VoidCallback onPressed,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.7),
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
      iconSize: 20,
      padding: EdgeInsets.all(4),
      constraints: BoxConstraints.tightFor(width: 30, height: 30),
    ),
  );
}


void _deleteUniversity(University university) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('تأكيد الحذف', style: cairoBold),
        content: Text('هل أنت متأكد أنك تريد حذف هذه الجامعة؟', style: cairoRegular),
        actions: <Widget>[
          TextButton(
            child: Text('إلغاء', style: cairoRegular),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('حذف', style: cairoRegular.copyWith(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(educationPathwayProvider.notifier).deleteUniversity(
                    _selectedPathway!.id,
                    _selectedSpecialization!.id,
                    university.id,
                  );
              setState(() {}); // Refresh the UI
            },
          ),
        ],
      );
    },
  );
}



  void _showUniversityDetails(University university) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UniversityDetailsScreen(university: university),
      ),
    );
  }

  void _editUniversity(University university) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UniversityCustomizationScreen(
          university: university,
          pathwayId: _selectedPathway!.id,
          specializationId: _selectedSpecialization!.id,
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
                  style: cairoRegular.copyWith(fontSize: 16),
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

  void _showAddDialog(BuildContext context) {
    if (_selectedSpecialization != null) {
      _showAddUniversityDialog(context);
    } else if (_selectedPathway != null) {
      _showAddSpecializationDialog(context);
    } else {
      _showAddPathwayDialog(context);
    }
  }

  void _showAddPathwayDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _imageUrl = '';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('إضافة مسار جديد', style: cairoBold),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'اسم المسار',
                  labelStyle: cairoRegular,
                ),
                style: TextStyle(color: Colors.black), // Add this line
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم المسار' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  labelStyle: cairoRegular,
                ),
                style: TextStyle(color: Colors.black), // Add this line
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال وصف المسار' : null,
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'رابط الصورة',
                  labelStyle: cairoRegular,
                ),
                style: TextStyle(color: Colors.black), // Add this line
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال رابط الصورة' : null,
                onSaved: (value) => _imageUrl = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('إلغاء', style: cairoRegular),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('إضافة', style: cairoSemiBold),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final newPathway = EducationPathway(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _name,
                description: _description,
                imageUrl: _imageUrl,
                specializations: [],
              );
              ref.read(educationPathwayProvider.notifier).addPathway(newPathway);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    ),
  );
}
  void _showAddSpecializationDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('إضافة تخصص جديد', style: cairoBold),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'اسم التخصص',
                  labelStyle: cairoRegular,
                ),
                style: TextStyle(color: Colors.black), // Set text color to black
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم التخصص' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  labelStyle: cairoRegular,
                ),
                style: TextStyle(color: Colors.black), // Set text color to black
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال وصف التخصص' : null,
                onSaved: (value) => _description = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('إلغاء', style: cairoRegular),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('إضافة', style: cairoSemiBold),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final newSpecialization = Specialization(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _name,
                description: _description,
                universities: [],
              );
              _selectedPathway!.specializations.add(newSpecialization);
              ref.read(educationPathwayProvider.notifier).updatePathway(_selectedPathway!);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    ),
  );
}

  void _showAddUniversityDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UniversityCustomizationScreen(
          pathwayId: _selectedPathway!.id,
          specializationId: _selectedSpecialization!.id,
        ),
      ),
    );
  }


  void _showEditUniversityDialog(University university) {
    final _formKey = GlobalKey<FormState>();
    String _name = university.name;
    String _description = university.description;
    String _website = university.website;
    String _imageUrl = university.imageUrl;
    File? _image;
    final picker = ImagePicker();

    Future getImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('تعديل الجامعة', style: cairoBold),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: _name,
                    decoration: InputDecoration(labelText: 'اسم الجامعة', labelStyle: cairoRegular),
                    validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم الجامعة' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  TextFormField(
                    initialValue: _description,
                    decoration: InputDecoration(labelText: 'الوصف', labelStyle: cairoRegular),
                    validator: (value) => value!.isEmpty ? 'الرجاء إدخال وصف الجامعة' : null,
                    onSaved: (value) => _description = value!,
                  ),
                  TextFormField(
                    initialValue: _website,
                    decoration: InputDecoration(labelText: 'الموقع الإلكتروني', labelStyle: cairoRegular),
                    validator: (value) => value!.isEmpty ? 'الرجاء إدخال الموقع الإلكتروني' : null,
                    onSaved: (value) => _website = value!,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('تغيير صورة الجامعة', style: cairoRegular),
                    onPressed: () async {
                      await getImage();
                      setState(() {});
                    },
                  ),
                  if (_image != null)
                    Image.file(_image!, height: 100)
                  else if (_imageUrl.isNotEmpty)
                    Image.network(_imageUrl, height: 100)
                  else
                    Text('لا توجد صورة', style: cairoRegular),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('إلغاء', style: cairoRegular),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('حفظ التغييرات', style: cairoSemiBold),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (_image != null) {
                    final ref = FirebaseStorage.instance
                        .ref()
                        .child('university_images')
                        .child('${DateTime.now().toIso8601String()}.jpg');
                    await ref.putFile(_image!);
                    _imageUrl = await ref.getDownloadURL();
                  }
                  final updatedUniversity = University(
                    id: university.id,
                    name: _name,
                    description: _description,
                    website: _website,
                    imageUrl: _imageUrl,
                  );
                  int universityIndex = _selectedSpecialization!.universities.indexWhere((u) => u.id == university.id);
                  _selectedSpecialization!.universities[universityIndex] = updatedUniversity;
                  ref.read(educationPathwayProvider.notifier).updatePathway(_selectedPathway!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deletePathway(String pathwayId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف', style: cairoBold),
        content: Text('هل أنت متأكد من حذف هذا المسار التعليمي؟', style: cairoRegular),
        actions: [
          TextButton(
            child: Text('إلغاء', style: cairoRegular),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('حذف', style: cairoRegular.copyWith(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (result == true) {
      ref.read(educationPathwayProvider.notifier).deletePathway(pathwayId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف المسار التعليمي', style: cairoRegular))
      );
    }
  }

  

}

extension ListExtension<T> on List<T> {
  T? get lastOrNull => isNotEmpty ? last : null;
}