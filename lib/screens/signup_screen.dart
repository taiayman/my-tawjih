import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taleb_edu_platform/providers/auth_provider.dart';
import 'package:taleb_edu_platform/services/auth_service.dart';
import 'package:taleb_edu_platform/widgets/glassmorphic_container.dart';
import 'package:taleb_edu_platform/widgets/animated_gradient_background.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart' hide LinearGradient;

class SignUpScreen extends ConsumerStatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _regionPointController;
  late TextEditingController _nationalPointController;
  String? _selectedGender;
  String? _selectedBranch;
  File? _profileImage;
  final List<String> _genders = ['ذكر', 'أنثى'];
  final List<String> _branches = [
    'العلوم التجريبية',
    'العلوم الرياضية',
    'الآداب والعلوم الإنسانية',
    'التسيير والتسويق',
    'التكنولوجيا',
    'اللغات الأجنبية',
    'التعليم الأصلي',
    'غير ذلك',
  ];

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _usernameController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _regionPointController = TextEditingController();
    _nationalPointController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _regionPointController.dispose();
    _nationalPointController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        print("Attempting to sign up");
        final authService = ref.read(authServiceProvider);
        await authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _usernameController.text.trim(),
          additionalInfo: {
            'name': _nameController.text.trim(),
            'gender': _selectedGender,
            'branch': _selectedBranch,
            'regionPoint': _regionPointController.text,
            'nationalPoint': _nationalPointController.text,
          },
          profileImage: _profileImage,
        );
        print("Sign up successful, navigating to home");
        context.go('/home');
      } catch (e) {
        print('Error in _signUp method: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ÙØ´Ù„ Ø§Ù„ØªØ³Ø¬ÙŠÙ„: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedGradientBackground(controller: _animationController),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLogo(),
                      SizedBox(height: 20),
                      _buildWelcomeText(),
                      SizedBox(height: 40),
                      _buildSignUpForm(),
                      SizedBox(height: 24),
                      _buildSignInPrompt(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: Container(
        height: 120,
        width: 120,
        child: RiveAnimation.asset(
          'assets/animations/taleb_logo.riv',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إنشاء حساب',
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'قم بالتسجيل لبدء رحلتك التعليمية',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return GlassmorphicContainer(
      borderRadius: 20,
      blur: 20,
      padding: EdgeInsets.all(24),
      alignment: Alignment.bottomCenter,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFffffff).withOpacity(0.1),
          Color(0xFFFFFFFF).withOpacity(0.05),
        ],
        stops: [0.1, 1],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileImagePicker(),
            SizedBox(height: 16),
            _buildTextField(
              controller: _usernameController,
              hintText: 'اسم المستخدم',
              prefixIcon: Icons.person_outline,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              hintText: 'الاسم الكامل',
              prefixIcon: Icons.person,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              hintText: 'البريد الإلكتروني',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _regionPointController,
              hintText: 'نقطة الجهوي',
              prefixIcon: Icons.grade_outlined,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _nationalPointController,
              hintText: 'نقطة الوطني',
              prefixIcon: Icons.grade,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildDropdown(
              value: _selectedGender,
              items: _genders,
              hint: 'الجنس',
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            SizedBox(height: 16),
            _buildDropdown(
              value: _selectedBranch,
              items: _branches,
              hint: 'الشعبة',
              onChanged: (value) {
                setState(() {
                  _selectedBranch = value;
                });
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              hintText: 'كلمة المرور',
              prefixIcon: Icons.lock_outline,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _confirmPasswordController,
              hintText: 'تأكيد كلمة المرور',
              prefixIcon: Icons.lock_outline,
              obscureText: !_isConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                },
              ),
            ),
            SizedBox(height: 24),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white.withOpacity(0.3),
        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
        child: _profileImage == null
            ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.cairo(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.cairo(color: Colors.white60),
        prefixIcon: Icon(prefixIcon, color: Colors.white70),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: TextDirection.rtl,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'هذا الحقل مطلوب';
        }
        if (controller == _confirmPasswordController && value != _passwordController.text) {
          return 'كلمات المرور غير متطابقة';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      style: GoogleFonts.cairo(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      dropdownColor: Colors.blue[900],
      validator: (value) => value == null ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text('إنشاء حساب', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white.withOpacity(0.38),
          disabledBackgroundColor: Colors.white.withOpacity(0.12),
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'هل لديك حساب؟',
          style: GoogleFonts.cairo(color: Colors.white70),
        ),
        TextButton(
          onPressed: () => context.go('/signin'),
          child: Text(
            'تسجيل الدخول',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}