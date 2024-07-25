import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taleb_edu_platform/models/announcement_model.dart';
import 'package:taleb_edu_platform/providers/language_provider.dart';
import 'package:taleb_edu_platform/screens/admin_dashboard.dart';
import 'package:taleb_edu_platform/screens/admin_education_pathway_screen.dart';
import 'package:taleb_edu_platform/screens/admin_institution_screen.dart';
import 'package:taleb_edu_platform/screens/admin_notification.dart';
import 'package:taleb_edu_platform/screens/mostajadat_screen.dart';
import 'package:taleb_edu_platform/screens/support_screen.dart';
import 'package:taleb_edu_platform/screens/profile_screen.dart';
import 'package:taleb_edu_platform/screens/institutions_screen.dart';
import 'package:taleb_edu_platform/screens/jobs_screen.dart';
import 'package:taleb_edu_platform/screens/guidance_screen.dart';
import 'package:taleb_edu_platform/screens/notifications_screen.dart';
import 'package:taleb_edu_platform/screens/web_view_screen.dart';
import 'package:taleb_edu_platform/widgets/announcement_carousel.dart';
import 'package:taleb_edu_platform/widgets/custom_bottom_navigation.dart';
import 'package:taleb_edu_platform/providers/announcement_provider.dart' as announcement_provider;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  late NotificationsScreen _notificationsScreen;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _setupNotifications();
    _notificationsScreen = NotificationsScreen();
  }

  void _setupNotifications() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleInitialMessage(initialMessage);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received foreground message: ${message.messageId}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Opened app from background state: ${message.messageId}");
      _handleBackgroundMessage(message);
    });
  }

  void _handleInitialMessage(RemoteMessage message) {
    print("Handling initial message: ${message.messageId}");
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print("Handling background message: ${message.messageId}");
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


void _showAnnouncementDetails(Announcement announcement) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(announcement.date),
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          _buildEducationLevelChip(announcement.category),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              announcement.schoolName,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Description'.tr(),
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildRichTextWithLinks(announcement.description),
                      SizedBox(height: 24),
                      Text(
                        'Full Details'.tr(),
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildRichTextWithLinks(announcement.fullText),
                      SizedBox(height: 24),
                      if (announcement.officialDocumentUrl != null)
                        _buildActionButton(
                          'View Official Document'.tr(),
                          announcement.officialDocumentUrl!,
                          Icons.description,
                        ),
                      if (announcement.registrationLink != null)
                        _buildActionButton(
                          'Register'.tr(),
                          announcement.registrationLink!,
                          Icons.app_registration,
                        ),
                      if (announcement.applicationDetails != null)
                        ..._buildApplicationDetails(announcement.applicationDetails!),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildRichTextWithLinks(String text) {
  List<InlineSpan> textSpans = [];
  RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
  Iterable<RegExpMatch> matches = exp.allMatches(text);
  int start = 0;

  for (RegExpMatch match in matches) {
    if (match.start > start) {
      textSpans.add(TextSpan(
        text: text.substring(start, match.start),
        style: GoogleFonts.cairo(fontSize: 16, color: Colors.black87),
      ));
    }
    textSpans.add(TextSpan(
      text: match.group(0),
      style: GoogleFonts.cairo(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()
        ..onTap = () => _launchURL(match.group(0)!),
    ));
    start = match.end;
  }

  if (start < text.length) {
    textSpans.add(TextSpan(
      text: text.substring(start),
      style: GoogleFonts.cairo(fontSize: 16, color: Colors.black87),
    ));
  }

  return RichText(text: TextSpan(children: textSpans));
}

Widget _buildActionButton(String label, String url, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: ElevatedButton.icon(
      onPressed: () => _launchURL(url),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.cairo(fontSize: 16),
      ),
    ),
  );
}

List<Widget> _buildApplicationDetails(Map<String, dynamic> details) {
  return [
    SizedBox(height: 16),
    Text(
      'Application Details'.tr(),
      style: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    SizedBox(height: 8),
    ...details.entries.map((entry) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${entry.key}: ',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              entry.value.toString(),
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    )).toList(),
  ];
}

void _launchURL(String url) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => WebViewScreen(url: url),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final announcementsAsyncValue = ref.watch(announcement_provider.announcementsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(announcementsAsyncValue),
          MostajadatScreen(),
          SupportScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildHomeContent(AsyncValue<List<Announcement>> announcementsAsyncValue) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 250),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: _buildWelcomeText(),
                  ),
                  _buildAnnouncementCarousel(announcementsAsyncValue),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategories(),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/images/my.png',
                    width: 35,
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                },
                child: Text(
                  'Taleb Educational Platform'.tr(),
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _notificationsScreen),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.language, color: Colors.black),
                onPressed: () {
                  _showLanguageDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [],
      leadingWidth: 0,
      leading: SizedBox(),
    );
  }

  Widget _buildWelcomeText() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Align(
        alignment: context.locale.languageCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          'الإعلانات'.tr(),
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: context.locale.languageCode == 'ar' ? TextAlign.right : TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildAnnouncementCarousel(AsyncValue<List<Announcement>> announcementsAsyncValue) {
    return SizedBox(
      height: 300,
      child: announcementsAsyncValue.when(
        data: (announcements) => AnnouncementCarousel(
          announcements: announcements,
          onAnnouncementTap: _showAnnouncementDetails,
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('error_loading_announcements'.tr())),
      ),
    );
  }

  Widget _buildCategories() {
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12, right: 16),
          child: Align(
            alignment: context.locale.languageCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              'الفئات'.tr(),
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: context.locale.languageCode == 'ar' ? TextAlign.right : TextAlign.left,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminEducationPathwayScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('مسارات التعليم'.tr()),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('لوحة تحكم'.tr()),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminNotificationScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('إرسال إشعار'.tr()),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth - 32;
              double middleWidth = totalWidth * 0.4;
              double sideWidth = (totalWidth - middleWidth) / 2;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryItem(
                    FontAwesomeIcons.newspaper,
                    'institutions_label'.tr(),
                    InstitutionsScreen(),
                    primaryColor,
                    accentColor,
                    sideWidth,
                  ),
                  SizedBox(width: 8),
                  _buildCategoryItem(
                    FontAwesomeIcons.briefcase,
                    'jobs_label'.tr(),
                    JobsScreen(),
                    primaryColor,
                    accentColor,
                    middleWidth,
                  ),
                  SizedBox(width: 8),
                  _buildCategoryItem(
                    FontAwesomeIcons.graduationCap,
                    'guidance_label'.tr(),
                    GuidanceScreen(),
                    primaryColor,
                    accentColor,
                    sideWidth,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    IconData icon,
    String title,
    Widget screen,
    Color primaryColor,
    Color accentColor,
    double width
  ) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: primaryColor),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final List<LanguageOption> languages = [
      LanguageOption('العربية', 'ar', '🇸🇦'),
      LanguageOption('English', 'en', '🇺🇸'),
      LanguageOption('Français', 'fr', '🇫🇷'),
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'select_language'.tr(),
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              ...languages.map((language) => _buildLanguageOption(language, context)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(LanguageOption language, BuildContext context) {
    final isSelected = context.locale.languageCode == language.code;
    return InkWell(
      onTap: () {
        final newLocale = Locale(language.code);
        context.setLocale(newLocale);
        ref.read(languageProvider.notifier).setLanguage(newLocale);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Text(
              language.flag,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(width: 16),
            Text(
              language.name,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
            Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationLevelChip(String category) {
    Color chipColor;
    String label;
    switch (category) {
      case 'bac':
        chipColor = Colors.green;
        label = 'باك';
        break;
      case 'bac+2':
        chipColor = Colors.blue;
        label = 'باك+2';
        break;
      default:
        chipColor = Colors.orange;
        label = category;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class LanguageOption {
  final String name;
  final String code;
  final String flag;

  LanguageOption(this.name, this.code, this.flag);
}