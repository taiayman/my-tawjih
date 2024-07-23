import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notifications_screen.dart';

class AdminNotificationScreen extends ConsumerStatefulWidget {
  const AdminNotificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminNotificationScreen> createState() => _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends ConsumerState<AdminNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSending = true);
      try {
        await ref.read(notificationServiceProvider).sendNotificationToAllUsers(
          title: _titleController.text,
          body: _bodyController.text,
        );
        
        // Save the notification locally
        final userNotification = UserNotification(
          title: _titleController.text,
          body: _bodyController.text,
          timestamp: DateTime.now(),
        );
        await _saveNotificationLocally(userNotification);
        
        _showSnackBar('تم إرسال الإشعار بنجاح', Colors.green);
        _titleController.clear();
        _bodyController.clear();
      } catch (e) {
        _showSnackBar('فشل في إرسال الإشعار: $e', Colors.red);
      } finally {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _saveNotificationLocally(UserNotification userNotification) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList('notifications') ?? [];
    notificationsJson.insert(0, jsonEncode(userNotification.toJson()));
    await prefs.setStringList('notifications', notificationsJson);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            'إرسال إشعار',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'تفاصيل الإشعار',
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _titleController,
                    hint: 'عنوان الإشعار',
                    icon: Icons.title,
                    validator: (value) => value?.isEmpty ?? true ? 'الرجاء إدخال العنوان' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _bodyController,
                    hint: 'نص الإشعار',
                    icon: Icons.message,
                    maxLines: 4,
                    validator: (value) => value?.isEmpty ?? true ? 'الرجاء إدخال نص الإشعار' : null,
                  ),
                  const SizedBox(height: 40),
                  _buildSendButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: const Color(0xFFFF5E62)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.cairo(color: const Color(0xFF333333)),
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5E62).withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSending ? null : _sendNotification,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: _isSending
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'إرسال الإشعار',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}