import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:taleb_edu_platform/routes.dart';
import 'package:taleb_edu_platform/theme.dart';

class TalebApp extends ConsumerWidget {
  const TalebApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Taleb Educational Platform'.tr(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      builder: (context, child) {
        return Scaffold(
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 50,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Taleb Educational Platform',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: child!),
            ],
          ),
        );
      },
    );
  }
}