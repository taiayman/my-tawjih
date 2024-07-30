import 'package:flutter/material.dart';
import 'package:taleb_edu_platform/models/institution_model.dart';
import 'package:taleb_edu_platform/services/institution_service.dart';
import 'package:taleb_edu_platform/screens/faculty_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class InstitutionDetailsScreen extends StatefulWidget {
  final Institution institution;

  InstitutionDetailsScreen({required this.institution});

  @override
  _InstitutionDetailsScreenState createState() => _InstitutionDetailsScreenState();
}

class _InstitutionDetailsScreenState extends State<InstitutionDetailsScreen> {
  final InstitutionService _institutionService = InstitutionService();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Colors.black54),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            widget.institution.name,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SafeArea(
          child: AnimationLimiter(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.institution.categories.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: CategoryListItem(
                        institutionId: widget.institution.id,
                        category: widget.institution.categories[index],
                        onTap: () => _navigateToCategoryDetails(widget.institution.id, widget.institution.categories[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addNewCategory,
          icon: Icon(Icons.add),
          label: Text('إضافة فئة'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  void _navigateToCategoryDetails(String institutionId, UniversityCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailsScreen(institutionId: institutionId, category: category),
      ),
    ).then((value) => setState(() {}));
  }

  void _addNewCategory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return NewCategoryForm(
          onCategoryAdded: (UniversityCategory newCategory) {
            setState(() {
              widget.institution.categories.add(newCategory);
            });
          },
        );
      },
    );
  }
}

class CategoryListItem extends StatelessWidget {
  final String institutionId;
  final UniversityCategory category;
  final VoidCallback onTap;

  const CategoryListItem({
    Key? key,
    required this.institutionId,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        '${category.faculties.length} كليات',
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor),
                      onPressed: onTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'حذف',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => _deleteCategory(context, institutionId, category),
        ),
      ],
    );
  }

  void _deleteCategory(BuildContext context, String institutionId, UniversityCategory category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تأكيد الحذف', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.black87)),
          content: Text('هل أنت متأكد من حذف هذه الفئة؟', style: GoogleFonts.cairo(color: Colors.black87)),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await InstitutionService().deleteCategory(institutionId, category.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف الفئة', style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      (context as Element).markNeedsBuild(); // Rebuild the widget
    }
  }
}

class NewCategoryForm extends StatefulWidget {
  final Function(UniversityCategory) onCategoryAdded;

  const NewCategoryForm({Key? key, required this.onCategoryAdded}) : super(key: key);

  @override
  _NewCategoryFormState createState() => _NewCategoryFormState();
}

class _NewCategoryFormState extends State<NewCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  final InstitutionService _institutionService = InstitutionService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إضافة فئة جديدة',
                style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'اسم الفئة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                style: TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الفئة';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('إضافة الفئة', style: GoogleFonts.cairo(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitForm,
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newCategory = UniversityCategory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name,
        faculties: [],
      );
      await _institutionService.addCategory(newCategory.id, newCategory);
      widget.onCategoryAdded(newCategory);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة الفئة بنجاح', style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

class CategoryDetailsScreen extends StatefulWidget {
  final String institutionId;
  final UniversityCategory category;

  CategoryDetailsScreen({required this.institutionId, required this.category});

  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final InstitutionService _institutionService = InstitutionService();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Colors.black54),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            widget.category.name,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SafeArea(
          child: AnimationLimiter(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.category.faculties.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: FacultyListItem(
                        institutionId: widget.institutionId,
                        categoryId: widget.category.id,
                        faculty: widget.category.faculties[index],
                        onTap: () => _navigateToFacultyDetails(widget.institutionId, widget.category.id, widget.category.faculties[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addNewFaculty(widget.institutionId, widget.category.id),
          icon: Icon(Icons.add),
          label: Text('إضافة كلية'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  void _navigateToFacultyDetails(String institutionId, String categoryId, Faculty faculty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacultyDetailsScreen(institutionId: institutionId, categoryId: categoryId, faculty: faculty),
      ),
    ).then((value) => setState(() {}));
  }

  void _addNewFaculty(String institutionId, String categoryId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return NewFacultyForm(
          institutionId: institutionId,
          categoryId: categoryId,
          onFacultyAdded: (Faculty newFaculty) {
            setState(() {
              widget.category.faculties.add(newFaculty);
            });
          },
        );
      },
    );
  }
}

class FacultyListItem extends StatelessWidget {
  final String institutionId;
  final String categoryId;
  final Faculty faculty;
  final VoidCallback onTap;

  const FacultyListItem({
    Key? key,
    required this.institutionId,
    required this.categoryId,
    required this.faculty,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faculty.name,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  faculty.description,
                  style: GoogleFonts.cairo(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor),
                      onPressed: onTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'حذف',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => _deleteFaculty(context, institutionId, categoryId, faculty),
        ),
      ],
    );
  }

  void _deleteFaculty(BuildContext context, String institutionId, String categoryId, Faculty faculty) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تأكيد الحذف', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.black87)),
          content: Text('هل أنت متأكد من حذف هذه الكلية؟', style: GoogleFonts.cairo(color: Colors.black87)),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await InstitutionService().deleteFaculty(institutionId, categoryId, faculty.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف الكلية', style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      (context as Element).markNeedsBuild(); // Rebuild the widget
    }
  }
}

class NewFacultyForm extends StatefulWidget {
  final String institutionId;
  final String categoryId;
  final Function(Faculty) onFacultyAdded;

  const NewFacultyForm({Key? key, required this.institutionId, required this.categoryId, required this.onFacultyAdded}) : super(key: key);

  @override
  _NewFacultyFormState createState() => _NewFacultyFormState();
}

class _NewFacultyFormState extends State<NewFacultyForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  final InstitutionService _institutionService = InstitutionService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إضافة كلية جديدة',
                style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'اسم الكلية',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                style: TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الكلية';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'وصف الكلية',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                style: TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وصف الكلية';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
                maxLines: 3,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('إضافة الكلية', style: GoogleFonts.cairo(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitForm,
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newFaculty = Faculty(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name,
        description: _description,
      );
      await _institutionService.addFaculty(widget.institutionId, widget.categoryId, newFaculty);
      widget.onFacultyAdded(newFaculty);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة الكلية بنجاح', style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}