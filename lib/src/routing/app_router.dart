import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/auth/presentation/login_screen.dart';
import 'package:moneymate/src/features/auth/presentation/register_screen.dart';
import 'package:moneymate/src/features/onboarding/presentation/accept_invite_screen.dart';
import 'package:moneymate/src/features/onboarding/presentation/invite_partner_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home — Coming soon')),
        ),
      ),
      GoRoute(
        path: '/invite',
        builder: (context, state) => const InvitePartnerScreen(),
      ),
      GoRoute(
        path: '/accept-invite',
        builder: (context, state) => AcceptInviteScreen(
          initialCode: state.uri.queryParameters['code'],
        ),
      ),
    ],
  );
}
