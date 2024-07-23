import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputAction textInputAction;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.maxLines = 1,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.textInputAction = TextInputAction.next,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        labelStyle: GoogleFonts.cairo(color: Colors.grey.shade700),
        hintStyle: GoogleFonts.cairo(color: Colors.grey.shade500),
        suffixIcon: suffixIcon,
      ),
      style: GoogleFonts.cairo(color: Colors.black87),
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onTap: onTap,
      readOnly: readOnly,
      textInputAction: textInputAction,
    );
  }
}