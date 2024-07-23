import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/providers/auth_provider.dart';
import 'package:taleb_edu_platform/screens/home_screen.dart';
import 'package:taleb_edu_platform/screens/mostajadat_screen.dart';
import 'package:taleb_edu_platform/screens/signin_screen.dart';
import 'package:taleb_edu_platform/screens/signup_screen.dart';
import 'package:taleb_edu_platform/screens/profile_screen.dart';
import 'package:taleb_edu_platform/screens/splash_screen.dart';
import 'package:taleb_edu_platform/screens/error_screen.dart';
import 'package:taleb_edu_platform/services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignUpScreen(),
      ),
    GoRoute(
  path: '/mostajadat',
  builder: (context, state) => MostajadatScreen(),
),

      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfileScreen(),
      ),
     
    
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnLoginPage = state.location == '/signin';
      final isOnSignUpPage = state.location == '/signup';
      final isOnRegistrationPage = state.location == '/register';
      final isOnSplashScreen = state.location == '/';

      if (isOnSplashScreen) return null;

      if (!isLoggedIn && !isOnLoginPage && !isOnSignUpPage && !isOnRegistrationPage) {
        return '/signin';
      }

      if (isLoggedIn && (isOnLoginPage || isOnSignUpPage || isOnRegistrationPage)) {
        return '/home';
      }

      return null;
    },
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error.toString(),
    ),
  );
});