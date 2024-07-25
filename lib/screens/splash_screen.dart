import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends ConsumerStatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _fadeAnimation;
  late Animation _scaleAnimation;

  @override
  void initState() {
    super.initState();
    print("SplashScreen initState called");
    _checkForInitialMessage();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.easeIn))
    );

    _scaleAnimation = Tween(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0, curve: Curves.easeOut))
    );

    _controller.forward().then((_) {
      print("Animation completed");
    });
  }

  void _checkForInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("Initial message received: ${initialMessage.messageId}");
    }
    _navigateToLogin();
  }

  void _navigateToLogin() {
    print("Attempting to navigate to login screen");
    Future.delayed(Duration(milliseconds: 500), () {
      print("Navigation delay completed, going to /signin");
      if (mounted) {
        try {
          context.pushReplacement('/signin');
          print("Navigation to /signin successful");
        } catch (e) {
          print("Error navigating to /signin: $e");
        }
      } else {
        print("Widget is not mounted, cannot navigate");
      }
    });
  }

  @override
  void dispose() {
    print("SplashScreen dispose called");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("SplashScreen build called");
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school,
                      size: 100,
                      color: Color.fromARGB(255, 5, 29, 58),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/my.png',
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: context.locale.languageCode == 'ar' ? 16 : 8),
                        Text(
                          'Taleb Educational Platform'.tr(),
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'أكتشف مستقبلك، حقق طموحاتك',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}