import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taleb_edu_platform/routes.dart';
import 'package:taleb_edu_platform/services/notification_service.dart';
import 'package:taleb_edu_platform/services/firebase_service.dart';
import 'package:taleb_edu_platform/services/auth_service.dart';
import 'package:taleb_edu_platform/theme.dart';
import 'package:taleb_edu_platform/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize OneSignal
  OneSignal.shared.setAppId("3b76c84e-346f-4ee7-8e8f-ae54a407bc92");
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });

  // Set up OneSignal notification handler
  OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
    event.complete(event.notification);
  });

  // Set up background message handler
  OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    // Handle notification opened event
    print("Opened notification: ${result.notification.jsonRepresentation()}");
  });

  final container = ProviderContainer();

  // Initialize Firebase
  try {
    await FirebaseService().initializeFirebase();
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('ar'), Locale('en'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: Locale('ar'),
      child: ProviderScope(
        parent: container,
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
    _setupOneSignal();
  }

  Future<void> _loadSavedLanguage() async {
    final languageNotifier = ref.read(languageProvider.notifier);
    await languageNotifier.loadSavedLanguage();
  }

  void _setupOneSignal() {
    final notificationService = ref.read(notificationServiceProvider);
    notificationService.setupOneSignalHandlers();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final currentLocale = ref.watch(languageProvider);

    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: currentLocale,
      title: 'Taleb Educational Platform'.tr(),
      theme: lightTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

// This function will handle incoming notifications when the app is terminated
Future<void> backgroundMessageHandler(OSNotificationReceivedEvent notification) async {
  // Handle background message here
  print("Received notification in background: ${notification.notification.body}");

  // You can perform tasks here like updating local storage or sending an API request
  // Be cautious about what you do here as the app is not fully initialized in this state
}