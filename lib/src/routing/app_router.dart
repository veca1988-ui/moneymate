import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/auth/presentation/login_screen.dart';
import 'package:moneymate/src/features/auth/presentation/register_screen.dart';
import 'package:moneymate/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:moneymate/src/features/expenses/presentation/add_expense_screen.dart';
import 'package:moneymate/src/features/expenses/presentation/expenses_list_screen.dart';
import 'package:moneymate/src/features/onboarding/presentation/accept_invite_screen.dart';
import 'package:moneymate/src/features/onboarding/presentation/invite_partner_screen.dart';
import 'package:moneymate/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:moneymate/src/features/settings/presentation/privacy_settings_screen.dart';
import 'package:moneymate/src/features/settings/presentation/profile_screen.dart';
import 'package:moneymate/src/features/settings/presentation/settings_screen.dart';
import 'package:moneymate/src/features/budgets/presentation/add_budget_screen.dart';
import 'package:moneymate/src/features/reports/presentation/reports_screen.dart';
import 'package:moneymate/src/features/subscription/presentation/paywall_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.valueOrNull;

  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/onboarding';

      if (!isLoggedIn && !isAuthRoute) return '/onboarding';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
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
        pageBuilder: (context, state) {
          final coupleId = user?.coupleId;
          if (coupleId == null || coupleId.isEmpty) {
            return _fadeTransitionPage(
                child: const InvitePartnerScreen(), state: state);
          }
          return _fadeTransitionPage(
              child: DashboardScreen(coupleId: coupleId), state: state);
        },
      ),
      GoRoute(
        path: '/add-expense/:coupleId',
        builder: (context, state) => AddExpenseScreen(
          coupleId: state.pathParameters['coupleId']!,
        ),
      ),
      GoRoute(
        path: '/edit-expense/:coupleId',
        builder: (context, state) => AddExpenseScreen(
          coupleId: state.pathParameters['coupleId']!,
          expense: state.extra as Expense?,
        ),
      ),
      GoRoute(
        path: '/expenses/:coupleId',
        pageBuilder: (context, state) {
          final coupleId = state.pathParameters['coupleId']!;
          final month = state.uri.queryParameters['month'] ?? _currentMonth();
          return _fadeTransitionPage(
              child: ExpensesListScreen(coupleId: coupleId, month: month),
              state: state);
        },
      ),
      GoRoute(
        path: '/add-budget/:coupleId',
        builder: (context, state) => AddBudgetScreen(
          coupleId: state.pathParameters['coupleId']!,
        ),
      ),
      GoRoute(
        path: '/reports/:coupleId',
        pageBuilder: (context, state) => _fadeTransitionPage(
          child: ReportsScreen(coupleId: state.pathParameters['coupleId']!),
          state: state,
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
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _fadeTransitionPage(
          child: const SettingsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (context, state) {
          final coupleId = user?.coupleId;
          if (coupleId == null || coupleId.isEmpty) {
            return const InvitePartnerScreen();
          }
          return PrivacySettingsScreen(coupleId: coupleId);
        },
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const PaywallScreen(),
      ),
    ],
  );
}

String _currentMonth() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
}

CustomTransitionPage<void> _fadeTransitionPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
