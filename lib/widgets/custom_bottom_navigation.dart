import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home_rounded, 'home'.tr(), 0),
                _buildNavItem(context, Icons.school_rounded, 'mostajadat'.tr(), 1),
                _buildNavItem(context, Icons.support_agent_rounded, 'support'.tr(), 2),
                _buildNavItem(context, Icons.person_rounded, 'profile'.tr(), 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 7 : 4),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                ),
              ),
              SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleNotificationNavigation(BuildContext context, String screen) {
    switch (screen) {
      case 'home':
        // Navigate to home screen
        break;
      case 'mostajadat':
        // Navigate to mostajadat screen
        break;
      case 'support':
        // Navigate to support screen
        break;
      case 'profile':
        // Navigate to profile screen
        break;
      default:
        // Default navigation
        break;
    }
  }
}