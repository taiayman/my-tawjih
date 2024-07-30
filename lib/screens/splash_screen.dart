import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends ConsumerStatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation _fadeAnimation;
  late Animation _scaleAnimation;
  bool _isTimerActive = false;
  bool _facebookLinkTapped = false;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetNavigationTimer();
    }
  }

  void _checkForInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("Initial message received: ${initialMessage.messageId}");
    }
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    print("Scheduling navigation to login screen");
    _isTimerActive = true;
    Future.delayed(Duration(seconds: _isInitialLoad ? 3 : 1), () {
      if (mounted && _isTimerActive && !_facebookLinkTapped) {
        _navigateToLogin();
      }
    });
    _isInitialLoad = false;
  }

  void _resetNavigationTimer() {
    setState(() {
      _isTimerActive = false;
      _facebookLinkTapped = false;
    });
    _scheduleNavigation();
  }

  void _navigateToLogin() {
    print("Attempting to navigate to login screen");
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
  }

  Future<void> _launchFacebook() async {
    setState(() {
      _facebookLinkTapped = true;
    });

    final Uri fbUrl = Uri.parse('https://www.facebook.com/AymantaiX?mibextid=ZbWKwL');
    
    try {
      bool launched = await launchUrl(
        fbUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // If launching in external application failed, try launching in browser
        launched = await launchUrl(
          fbUrl,
          mode: LaunchMode.platformDefault,
        );
      }
      if (!launched) {
        print('Could not launch Facebook');
      }
    } catch (e) {
      print('Error launching Facebook: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print("SplashScreen dispose called");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("SplashScreen build called");
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: GestureDetector(
              onTap: _launchFacebook,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(text: 'من تطوير '),
                    TextSpan(
                      text: 'أيمن الطائي',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}