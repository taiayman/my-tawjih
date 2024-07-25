import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:taleb_edu_platform/models/announcement_model.dart';
import 'package:taleb_edu_platform/models/message_model.dart';
import 'package:taleb_edu_platform/models/mostajadat_modal.dart';
import 'package:taleb_edu_platform/models/news_model.dart';
import 'package:taleb_edu_platform/providers/announcement_provider.dart';
import 'package:taleb_edu_platform/providers/mostajadat_provider.dart';
import 'package:taleb_edu_platform/providers/news_provider.dart';
import 'package:taleb_edu_platform/screens/mostajadat_customization_screen.dart';
import 'package:taleb_edu_platform/services/firestore_service.dart';
import 'package:http/http.dart' as http;

class AdminDashboardScreen extends ConsumerStatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final Color primaryColor = Color(0xFF1E88E5);
  final Color accentColor = Color(0xFFFFA000);
  final Color backgroundColor = Color(0xFFF5F5F5);
  final Color cardColor = Color(0xFFFFFFFF);
  final Color textColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: primaryColor,
        hintColor: accentColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: cardColor,
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          titleTextStyle: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('لوحة تحكم الأدمن'),
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'الإعلانات'.tr()),
              Tab(text: 'المستجدات'.tr()),
              Tab(text: 'الرسائل'.tr()),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: accentColor,
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAnnouncementsTab(),
              _buildMostajadatTab(),
              AdminChatTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    final announcementsAsyncValue = ref.watch(announcementsProvider);

    return announcementsAsyncValue.when(
      data: (announcements) => ListView.builder(
        itemCount: announcements.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _showAddAnnouncementDialog(context),
                child: Text('إضافة إعلان'.tr()),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: accentColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          }
          return _buildAnnouncementCard(announcements[index - 1]);
        },
      ),
      loading: () => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: TextStyle(color: textColor)),
      ),
    );
  }

  Widget _buildMostajadatTab() {
    final Map<String, String> categoryMap = {
      'jobs': 'jobs_label',
      'guidance': 'guidance_label',
    };

    return DefaultTabController(
      length: categoryMap.length,
      child: Column(
        children: [
          TabBar(
            tabs: categoryMap.values
                .map((translationKey) => Tab(text: translationKey.tr()))
                .toList(),
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: accentColor,
          ),
          Expanded(
            child: TabBarView(
              children: categoryMap.keys.map((englishCategory) {
                return _buildMostajadatCategoryTab(englishCategory);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostajadatCategoryTab(String category) {
    final mostajadatAsyncValue = ref.watch(mostajadatProvider);

    return mostajadatAsyncValue.when(
      data: (mostajadatList) {
        final categoryMostajadat = mostajadatList
            .where((m) => m.category == category)
            .toList();
        return ListView.builder(
          itemCount: categoryMostajadat.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _showAddMostajadatDialog(context),
                  child: Text('إضافة مستجد'.tr()),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: accentColor,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            }
            return _buildMostajadatCard(categoryMostajadat[index - 1]);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

 
  Widget _buildNewsCard(News news) {
    return Card(
      color: cardColor,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          news.title,
          style: GoogleFonts.cairo(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          news.summary,
          style: GoogleFonts.cairo(color: textColor, fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: primaryColor),
              onPressed: () => _showEditNewsDialog(context, news),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, 'news', news.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return Card(
      color: cardColor,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          announcement.title,
          style: GoogleFonts.cairo(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          announcement.description,
          style: GoogleFonts.cairo(color: textColor, fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: primaryColor),
              onPressed: () => _showEditAnnouncementDialog(context, announcement),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _showDeleteConfirmation(context, 'announcements', announcement.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostajadatCard(Mostajadat mostajadat) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormat.format(mostajadat.date);

    return Dismissible(
      key: Key(mostajadat.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _showDeleteConfirmation(context, 'mostajadat', mostajadat.id);
        }
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        color: cardColor,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          title: Text(
            mostajadat.title,
            style: GoogleFonts.cairo(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mostajadat.description,
                style: GoogleFonts.cairo(color: textColor, fontSize: 14),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'تاريخ النشر: $formattedDate',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () => _showEditMostajadatDialog(context, mostajadat),
        ),
      ),
    );
  }

  void _showAddNewsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => NewsDialog(
        primaryColor: primaryColor,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        cardColor: cardColor,
        textColor: textColor,
      ),
    );
    
    }

  void _showEditNewsDialog(BuildContext context, News news) {
    showDialog(
      context: context,
      builder: (context) => NewsDialog(
        news: news,
        primaryColor: primaryColor,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        cardColor: cardColor,
        textColor: textColor,
      ),
    );
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AnnouncementDialog(
        primaryColor: primaryColor,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        cardColor: cardColor,
        textColor: textColor,
      ),
    );
  }

  void _showEditAnnouncementDialog(BuildContext context, Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AnnouncementDialog(
        announcement: announcement,
        primaryColor: primaryColor,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        cardColor: cardColor,
        textColor: textColor,
      ),
    );
  }

  void _showAddMostajadatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddMostajadatDialog(
        ref: ref,
      ),
    );
  }

  void _showEditMostajadatDialog(BuildContext context, Mostajadat mostajadat) {
    showDialog(
      context: context,
      builder: (context) => MostajadatCustomizationScreen(
        mostajadat: mostajadat,
        title: mostajadat.title,
        description: mostajadat.description,
        details: mostajadat.details,
        date: mostajadat.date,
        deadlineDate: mostajadat.deadlineDate,
        imageUrl: mostajadat.imageUrl,
        type: mostajadat.type,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String type, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف ${type == 'news' ? 'الخبر' : type == 'announcements' ? 'الإعلان' : 'المستجد'}'.tr(),
          style: GoogleFonts.cairo(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد أنك تريد حذف هذا ${type == 'news' ? 'الخبر' : type == 'announcements' ? 'الإعلان' : 'المستجد'}؟'.tr(),
          style: GoogleFonts.cairo(color: textColor),
        ),
        actions: [
          TextButton(
            child: Text(
              'إلغاء'.tr(),
              style: GoogleFonts.cairo(color: primaryColor),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(
              'حذف'.tr(),
              style: GoogleFonts.cairo(color: Colors.red),
            ),
            onPressed: () async {
              try {
                if (type == 'news') {
                  await ref.read(firestoreServiceProvider).deleteDocument(type, id);
                  ref.refresh(recentNewsProvider);
                } else if (type == 'announcements') {
                  await ref.read(firestoreServiceProvider).deleteDocument(type, id);
                  ref.refresh(announcementNotifierProvider);
                } else if (type == 'mostajadat') {
                  await ref.read(firestoreServiceProvider).deleteDocument(type, id);
                  ref.refresh(mostajadatProvider);
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${type == 'news' ? 'الخبر' : type == 'announcements' ? 'الإعلان' : 'المستجد'} تم حذفه بنجاح'.tr(),
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: accentColor,
                  ),
                );
              } catch (e) {
                print('Error deleting $type: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'حدث خطأ أثناء حذف $type: $e'.tr(),
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class NewsDialog extends ConsumerStatefulWidget {
  final News? news;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;

  NewsDialog({
    this.news,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
  });

  @override
  _NewsDialogState createState() => _NewsDialogState();
}

class _NewsDialogState extends ConsumerState<NewsDialog> {
  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late TextEditingController _contentController;
  late TextEditingController _imageUrlController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.news?.title ?? '');
    _summaryController = TextEditingController(text: widget.news?.summary ?? '');
    _contentController = TextEditingController(text: widget.news?.content ?? '');
    _imageUrlController = TextEditingController(text: widget.news?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.news == null ? 'إضافة خبر'.tr() : 'تعديل خبر'.tr(),
        style: GoogleFonts.cairo(color: widget.textColor, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: _titleController,
              labelText: 'العنوان'.tr(),
              icon: Icons.title,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _summaryController,
              labelText: 'الملخص'.tr(),
              icon: Icons.short_text,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _contentController,
              labelText: 'المحتوى'.tr(),
              icon: Icons.article,
              maxLines: 3,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _imageUrlController,
              labelText: 'رابط الصورة'.tr(),
              icon: Icons.image,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.add_photo_alternate),
              label: Text('اختيار صورة'.tr()),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: widget.accentColor,
              ),
            ),
            SizedBox(height: 16),
            if (_imageFile != null)
              Image.file(_imageFile!, height: 100, fit: BoxFit.cover)
            else if (widget.news != null && widget.news!.imageUrl != null)
              CachedNetworkImage(
                imageUrl: widget.news!.imageUrl!,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('إلغاء'.tr(), style: GoogleFonts.cairo(color: widget.primaryColor)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(
            widget.news == null ? 'إضافة'.tr() : 'حفظ'.tr(),
            style: GoogleFonts.cairo(),
          ),
          onPressed: () => _saveNews(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: widget.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.cairo(color: widget.textColor),
        prefixIcon: Icon(icon, color: widget.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.accentColor),
        ),
      ),
      style: GoogleFonts.cairo(color: widget.textColor),
    );
  }

  void _saveNews(BuildContext context) async {
    try {
      final news = News(
        id: widget.news?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        summary: _summaryController.text,
        content: _contentController.text,
        date: widget.news?.date ?? DateTime.now(),
        imageUrl: _imageUrlController.text,
        reactions: widget.news?.reactions ?? [],
        comments: widget.news?.comments ?? [],
      );

      if (widget.news == null) {
        await ref.read(firestoreServiceProvider).addDocument('news', news.toMap());
      } else {
        await ref.read(firestoreServiceProvider).updateDocument('news', news.id, news.toMap());
      }
      ref.refresh(recentNewsProvider);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الخبر بنجاح'.tr(), style: GoogleFonts.cairo()),
          backgroundColor: widget.accentColor,
        ),
      );
    } catch (e) {
      print('Error saving news: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حفظ الخبر: $e'.tr(), style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class AnnouncementDialog extends ConsumerStatefulWidget {
  final Announcement? announcement;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;

  AnnouncementDialog({
    this.announcement,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
  });

  @override
  _AnnouncementDialogState createState() => _AnnouncementDialogState();
}

class _AnnouncementDialogState extends ConsumerState<AnnouncementDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _fullTextController;
  late TextEditingController _schoolNameController;
  late TextEditingController _schoolImageUrlController;
  late String _category;
  File? _imageFile;
  DateTime _date = DateTime.now();
  String? _officialDocumentUrl;
  String? _registrationLink;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement?.title ?? '');
    _descriptionController = TextEditingController(text: widget.announcement?.description ?? '');
    _fullTextController = TextEditingController(text: widget.announcement?.fullText ?? '');
    _schoolNameController = TextEditingController(text: widget.announcement?.schoolName ?? '');
    _schoolImageUrlController = TextEditingController(text: widget.announcement?.schoolImageUrl ?? '');
    _category = widget.announcement?.category ?? 'other';
    _officialDocumentUrl = widget.announcement?.officialDocumentUrl;
    _registrationLink = widget.announcement?.registrationLink;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fullTextController.dispose();
    _schoolNameController.dispose();
    _schoolImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickFile(String field) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        if (field == 'officialDocumentUrl') {
          _officialDocumentUrl = result.files.single.path;
        } else if (field == 'registrationLink') {
          _registrationLink = result.files.single.path;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.announcement == null ? 'إضافة إعلان'.tr() : 'تعديل إعلان'.tr(),
        style: GoogleFonts.cairo(color: widget.textColor, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: _titleController,
              labelText: 'العنوان'.tr(),
              icon: Icons.title,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              labelText: 'الوصف'.tr(),
              icon: Icons.description,
              maxLines: 3,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _fullTextController,
              labelText: 'النص الكامل'.tr(),
              icon: Icons.article,
              maxLines: 5,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _schoolNameController,
              labelText: 'اسم المؤسسة'.tr(),
              icon: Icons.school,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _schoolImageUrlController,
              labelText: 'رابط صورة المؤسسة'.tr(),
              icon: Icons.image,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: 'الفئة'.tr(),
                labelStyle: GoogleFonts.cairo(color: widget.textColor),
                prefixIcon: Icon(Icons.category, color: widget.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.accentColor),
                ),
              ),
              style: GoogleFonts.cairo(color: widget.textColor),
              items: ['bac', 'bac+2', 'bac+3', 'other'].map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        primaryColor: widget.primaryColor,
                        colorScheme: ColorScheme.light(primary: widget.primaryColor),
                        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null && pickedDate != _date) {
                  setState(() {
                    _date = pickedDate;
                  });
                }
              },
              child: Text(
                'اختيار التاريخ: ${DateFormat('dd/MM/yyyy').format(_date)}',
                style: GoogleFonts.cairo(),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: widget.accentColor,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickFile('officialDocumentUrl'),
              child: Text(
                _officialDocumentUrl != null
                    ? 'تم اختيار الملف: ${path.basename(_officialDocumentUrl!)}'
                    : 'تحميل وثيقة رسمية (اختياري)',
                style: GoogleFonts.cairo(),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickFile('registrationLink'),
              child: Text(
                _registrationLink != null
                    ? 'تم اختيار الملف: ${path.basename(_registrationLink!)}'
                    : 'تحميل رابط التسجيل (اختياري)',
                style: GoogleFonts.cairo(),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            if (_imageFile != null)
              Image.file(_imageFile!, height: 100, fit: BoxFit.cover)
            else if (widget.announcement != null && widget.announcement!.schoolImageUrl != null)
              CachedNetworkImage(
                imageUrl: widget.announcement!.schoolImageUrl!,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('إلغاء'.tr(), style: GoogleFonts.cairo(color: widget.primaryColor)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(
            widget.announcement == null ? 'إضافة'.tr() : 'حفظ'.tr(),
            style: GoogleFonts.cairo(),
          ),
          onPressed: () => _saveAnnouncement(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: widget.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.cairo(color: widget.textColor),
        prefixIcon: Icon(icon, color: widget.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.accentColor),
        ),
      ),
      style: GoogleFonts.cairo(color: widget.textColor),
    );
  }

  void _saveAnnouncement(BuildContext context) async {
    try {
      if (_officialDocumentUrl != null && !_officialDocumentUrl!.startsWith('http')) {
        _officialDocumentUrl = await _uploadFile(_officialDocumentUrl!);
      }
      if (_registrationLink != null && !_registrationLink!.startsWith('http')) {
        _registrationLink = await _uploadFile(_registrationLink!);
      }

      final announcement = Announcement(
        id: widget.announcement?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category,
        date: _date,
        schoolName: _schoolNameController.text,
        schoolImageUrl: _schoolImageUrlController.text,
        fullText: _fullTextController.text,
        officialDocumentUrl: _officialDocumentUrl,
        registrationLink: _registrationLink,
      );

      if (widget.announcement == null) {
        await ref.read(firestoreServiceProvider).addDocument('announcements', announcement.toMap());
      } else {
        await ref.read(firestoreServiceProvider).updateDocument('announcements', announcement.id, announcement.toMap());
      }
      ref.refresh(announcementNotifierProvider);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الإعلان بنجاح'.tr(), style: GoogleFonts.cairo()),
          backgroundColor: widget.accentColor,
        ),
      );
    } catch (e) {
      print('Error saving announcement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حفظ الإعلان: $e'.tr(), style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadFile(String filePath) async {
    try {
      final fileName = path.basename(filePath);
      final storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
      final uploadTask = storageRef.putFile(File(filePath));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }
}


class AddMostajadatDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;

  AddMostajadatDialog({
    required this.ref,
  });

  @override
  _AddMostajadatDialogState createState() => _AddMostajadatDialogState();
}

class _AddMostajadatDialogState extends ConsumerState<AddMostajadatDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _details = '';
  String _category = 'الوظائف';
  DateTime _date = DateTime.now();
  DateTime? _deadlineDate;
  File? _imageFile;
  String _type = 'بدون';
  File? _cardImageFile;
  String? _cardImagePath;

  final List<String> _categories = [
    'الوظائف',
    'التوجيه',
  ];

  final List<String> _types = [
    'بدون',
    'باك',
    'باك+1',
    'باك+2',
    'باك+3',
    'باك+4',
    'باك+5',
    'أخرى',
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCardImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _cardImageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('إضافة مستجد', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  labelStyle: GoogleFonts.cairo(color: Colors.black),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال العنوان' : null,
                onSaved: (value) => _title = value!,
                style: GoogleFonts.cairo(color: Colors.black),
              ),
              SizedBox(height: 16),
              _imageFile != null
                  ? Image.file(_imageFile!, height: 100)
                  : ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('اختيار صورة', style: GoogleFonts.cairo()),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 16),
              _cardImageFile != null
                  ? ClipRRect( // Wrap the Image.file with ClipRRect
                      borderRadius: BorderRadius.circular(80.0), // Adjust radius as needed
                      child: Image.file(_cardImageFile!, height: 100),
                    )
                  : ElevatedButton(
                      onPressed: _pickCardImage,
                      child: Text('اختيار صورة للبطاقة', style: GoogleFonts.cairo()),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                    ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != _date) {
                    setState(() {
                      _date = pickedDate;
                    });
                  }
                },
                child: Text(
                  'اختيار تاريخ النشر: ${DateFormat('dd/MM/yyyy').format(_date)}',
                  style: GoogleFonts.cairo(),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _deadlineDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != _deadlineDate) {
                    setState(() {
                      _deadlineDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  _deadlineDate != null
                      ? 'اختيار تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(_deadlineDate!)}'
                      : 'اختيار تاريخ الانتهاء',
                  style: GoogleFonts.cairo(),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                items: _types.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: GoogleFonts.cairo()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'النوع',
                  labelStyle: GoogleFonts.cairo(color: Colors.black),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: GoogleFonts.cairo(color: Colors.black),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category, style: GoogleFonts.cairo()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'الفئة',
                  labelStyle: GoogleFonts.cairo(color: Colors.black),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: GoogleFonts.cairo(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text('التالي', style: GoogleFonts.cairo()),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }

   void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String imageUrl = ''; // Initialize imageUrl
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!); // Await the upload here
      }

      if (_cardImageFile != null) {
        _cardImagePath = await _uploadImage(_cardImageFile!);
      }

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MostajadatCustomizationScreen(
          title: _title,
          description: '',
          details: '',
          date: _date,
          deadlineDate: _deadlineDate,
          imageUrl: imageUrl, // Pass the uploaded image URL
          type: _type,
          cardImagePath: _cardImagePath,
        ),
      ));
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref().child('mostajadat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putFile(imageFile);
    return await storageRef.getDownloadURL();
  }
}
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class AdminChatTab extends ConsumerStatefulWidget {
  @override
  _AdminChatTabState createState() => _AdminChatTabState();
}

class _AdminChatTabState extends ConsumerState<AdminChatTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedUserId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('محادثة الأدمن', style: GoogleFonts.cairo()),
      ),
      drawer: _buildUserDrawer(),
      body: _selectedUserId != null
          ? _buildChatRoom()
          : _buildEmptyChat(),
    );
  }

  Widget _buildUserDrawer() {
    return Drawer(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.cairo()));
          } else {
            final users = snapshot.data!.docs;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userData = users[index].data() as Map<String, dynamic>;
                final userId = users[index].id;
                return _buildUserTile(userData, userId);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> userData, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('support_messages')
          .where('userId', isEqualTo: userId)
          .where('isAdminMessage', isEqualTo: false)
          .where('read', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: userData['photoUrl'] != null
                  ? NetworkImage(userData['photoUrl'])
                  : null,
            ),
            title: Text(userData['name'] ?? 'مستخدم غير معروف', style: GoogleFonts.cairo()),
            subtitle: Text(userData['email'] ?? '', style: GoogleFonts.cairo()),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text('خطأ في تحميل الرسائل', style: GoogleFonts.cairo()),
          );
        } else {
          final unreadCount = snapshot.data!.docs.length;
          return ListTile(
            onTap: () {
              setState(() {
                _selectedUserId = userId;
                Navigator.pop(context);
              });
            },
            leading: Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  backgroundImage: userData['photoUrl'] != null
                      ? NetworkImage(userData['photoUrl'])
                      : null,
                ),
                if (unreadCount > 0)
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$unreadCount',
                      style: GoogleFonts.cairo(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
            title: Text(userData['name'] ?? 'مستخدم غير معروف', style: GoogleFonts.cairo()),
            subtitle: Text(userData['email'] ?? '', style: GoogleFonts.cairo()),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          );
        }
      },
    );
  }

  Widget _buildChatRoom() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('support_messages')
          .where('userId', isEqualTo: _selectedUserId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.cairo()));
        } else {
          final messages = snapshot.data!.docs;
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    if (!messageData['isAdminMessage'] && !messageData['read']) {
                      _firestore
                          .collection('support_messages')
                          .doc(messages[index].id)
                          .update({'read': true});
                    }
                    return _buildMessageBubble(messageData);
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          );
        }
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData) {
    final bool isAdmin = messageData['isAdminMessage'] ?? false;
    final Timestamp? timestamp = messageData['timestamp'] as Timestamp?;

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isAdmin ? Colors.blue[100] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              messageData['content'] ?? '',
              style: GoogleFonts.cairo(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              timestamp != null
                  ? DateFormat('HH:mm').format(timestamp.toDate())
                  : 'الوقت غير متاح',
              style: GoogleFonts.cairo(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.cairo(),
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                hintStyle: GoogleFonts.cairo(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty && _selectedUserId != null) {
      final newMessage = {
        'content': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isAdminMessage': true,
        'userId': _selectedUserId,
        'read': false,
      };

      try {
        await _firestore.collection('support_messages').add(newMessage);
        _messageController.clear();
        Future.delayed(Duration(milliseconds: 100), _scrollToBottom);
      } catch (e) {
        print('Error sending message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الرسالة. الرجاء المحاولة مرة أخرى.', style: GoogleFonts.cairo())),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Text('اختر مستخدم لبدء الدردشة', style: GoogleFonts.cairo(fontSize: 18)),
    );
  }
}