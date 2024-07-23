import 'package:flutter/material.dart';
import 'package:taleb_edu_platform/models/institution_model.dart';
import 'package:taleb_edu_platform/services/institution_service.dart';
import 'package:taleb_edu_platform/screens/institution_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AdminInstitutionScreen extends StatefulWidget {
  @override
  _AdminInstitutionScreenState createState() => _AdminInstitutionScreenState();
}

class _AdminInstitutionScreenState extends State<AdminInstitutionScreen> {
  final InstitutionService _institutionService = InstitutionService();
  List<Institution> _institutions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
  }

  Future<void> _loadInstitutions() async {
    setState(() => _isLoading = true);
    List<Institution> institutions = await _institutionService.getInstitutions();
    setState(() {
      _institutions = institutions;
      _isLoading = false;
    });
  }

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
            'إدارة المؤسسات',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : AnimationLimiter(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _institutions.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: InstitutionListItem(
                              institution: _institutions[index],
                              onDelete: () => _deleteInstitution(index),
                              onTap: () => _navigateToInstitutionDetails(_institutions[index]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addNewInstitution,
          icon: Icon(Icons.add),
          label: Text('إضافة مؤسسة'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  void _navigateToInstitutionDetails(Institution institution) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstitutionDetailsScreen(institution: institution),
      ),
    ).then((value) => _loadInstitutions());
  }

  void _addNewInstitution() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return NewInstitutionForm(
          onInstitutionAdded: (Institution newInstitution) {
            setState(() {
              _institutions.add(newInstitution);
            });
          },
        );
      },
    );
  }

  Future<void> _deleteInstitution(int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تأكيد الحذف', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.black87)),
          content: Text('هل أنت متأكد من حذف هذه المؤسسة؟', style: GoogleFonts.cairo(color: Colors.black87)),
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
      await _institutionService.deleteInstitution(_institutions[index].id);
      setState(() {
        _institutions.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف المؤسسة', style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

class InstitutionListItem extends StatelessWidget {
  final Institution institution;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const InstitutionListItem({
    Key? key,
    required this.institution,
    required this.onTap,
    required this.onDelete,
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
                  institution.name,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  institution.description,
                  style: GoogleFonts.cairo(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        '${institution.categories.length} فئات',
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
          onTap: onDelete,
        ),
      ],
    );
  }
}

class NewInstitutionForm extends StatefulWidget {
  final Function(Institution) onInstitutionAdded;

  const NewInstitutionForm({Key? key, required this.onInstitutionAdded}) : super(key: key);

  @override
  _NewInstitutionFormState createState() => _NewInstitutionFormState();
}

class _NewInstitutionFormState extends State<NewInstitutionForm> {
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
                'إضافة مؤسسة جديدة',
                style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'اسم المؤسسة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                style: TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المؤسسة';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'وصف المؤسسة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                style: TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وصف المؤسسة';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
                maxLines: 3,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('إضافة المؤسسة', style: GoogleFonts.cairo(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Theme.of(context).primaryColor,
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
      final newInstitution = Institution(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name,
        description: _description,
        categories: [],
      );
      await _institutionService.addInstitution(newInstitution);
      widget.onInstitutionAdded(newInstitution);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة المؤسسة بنجاح', style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}