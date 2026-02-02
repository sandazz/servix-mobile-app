import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servix/features/auth/presentation/screens/login_screen.dart';
import 'package:servix/features/auth/presentation/screens/splash_screen.dart';
import 'package:servix/features/auth/providers/auth_provider.dart';
import 'package:servix/features/home/presentation/screens/home_screen.dart';
import 'package:servix/features/explore/presentation/screens/explore_screen.dart';
import 'package:servix/features/bookings/presentation/screens/bookings_screen.dart';
import 'package:servix/features/profile/presentation/screens/profile_screen.dart';
import 'package:servix/shared/widgets/main_shell.dart';
import 'package:servix/features/signup/presentation/screens/signup_select_type_screen.dart';
import 'package:servix/features/signup/presentation/screens/signup_select_account_screen.dart';
import 'package:servix/features/signup/presentation/screens/client/client_step1_screen.dart';
import 'package:servix/features/signup/presentation/screens/client/client_step2_screen.dart';
import 'package:servix/features/signup/presentation/screens/client/client_step3_screen.dart';
import 'package:servix/features/signup/presentation/screens/client/client_step4_screen.dart';
import 'package:servix/features/signup/presentation/screens/client/client_step5_screen.dart';
import 'package:servix/features/signup/presentation/screens/client/client_congratulation_screen.dart';
import 'package:servix/features/signup/presentation/screens/provider/provider_step1_screen.dart';
import 'package:servix/features/signup/presentation/screens/provider/provider_step2_screen.dart';
import 'package:servix/features/signup/presentation/screens/provider/provider_step3_screen.dart';
import 'package:servix/features/signup/presentation/screens/provider/provider_step4_screen.dart';
import 'package:servix/features/signup/presentation/screens/provider/provider_step5_screen.dart';
import 'package:servix/features/signup/presentation/screens/provider/provider_step6_screen.dart';
import 'package:servix/features/signup/presentation/screens/provider/provider_congratulation_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.value?.isAuthenticated ?? false;
      final isLoading = authState.isLoading;
      final currentPath = state.uri.path;

      // Don't redirect while loading
      if (isLoading) return null;

      // Auth routes that don't require login
      final publicRoutes = [
        '/',
        '/login',
        '/signup-select-type',
        '/signup-select-account',
      ];

      final isPublicRoute =
          publicRoutes.contains(currentPath) ||
          currentPath.startsWith('/signup-steps') ||
          currentPath.startsWith('/provider-signup');

      // If logged in and trying to access auth routes, redirect to home
      if (isLoggedIn && (currentPath == '/login' || currentPath == '/')) {
        return '/home';
      }

      // If not logged in and trying to access protected routes
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // Auth Routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // Signup Type Selection
      GoRoute(
        path: '/signup-select-type',
        builder: (context, state) => const SignupSelectTypeScreen(),
      ),

      // Signup Account Type Selection (for clients)
      GoRoute(
        path: '/signup-select-account',
        builder: (context, state) => const SignupSelectAccountScreen(),
      ),

      // Client Signup Steps
      GoRoute(
        path: '/signup-steps/step1',
        builder: (context, state) => const ClientStep1Screen(),
      ),
      GoRoute(
        path: '/signup-steps/step2',
        builder: (context, state) => const ClientStep2Screen(),
      ),
      GoRoute(
        path: '/signup-steps/step3',
        builder: (context, state) => const ClientStep3Screen(),
      ),
      GoRoute(
        path: '/signup-steps/step4',
        builder: (context, state) => const ClientStep4Screen(),
      ),
      GoRoute(
        path: '/signup-steps/step5',
        builder: (context, state) => const ClientStep5Screen(),
      ),
      GoRoute(
        path: '/signup-steps/congratulation',
        builder: (context, state) => const ClientCongratulationScreen(),
      ),

      // Provider Signup Steps
      GoRoute(
        path: '/provider-signup/step1',
        builder: (context, state) => const ProviderStep1Screen(),
      ),
      GoRoute(
        path: '/provider-signup/step2',
        builder: (context, state) => const ProviderStep2Screen(),
      ),
      GoRoute(
        path: '/provider-signup/step3',
        builder: (context, state) => const ProviderStep3Screen(),
      ),
      GoRoute(
        path: '/provider-signup/step4',
        builder: (context, state) => const ProviderStep4Screen(),
      ),
      GoRoute(
        path: '/provider-signup/step5',
        builder: (context, state) => const ProviderStep5Screen(),
      ),
      GoRoute(
        path: '/provider-signup/step6',
        builder: (context, state) => const ProviderStep6Screen(),
      ),
      GoRoute(
        path: '/provider-signup/congratulation',
        builder: (context, state) => const ProviderCongratulationScreen(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ExploreScreen(
                initialCategory: state.uri.queryParameters['category'],
              ),
            ),
          ),
          GoRoute(
            path: '/bookings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BookingsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});
