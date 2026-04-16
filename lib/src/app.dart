import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/src/constants/app_theme.dart';
import 'package:moneymate/src/constants/theme_provider.dart';
import 'package:moneymate/src/routing/app_router.dart';

class MoneyMateApp extends ConsumerWidget {
  const MoneyMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    return MaterialApp.router(
      title: 'MoneyMate',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        );
      },
    );
  }
}
