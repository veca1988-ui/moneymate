import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/src/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  Widget createOnboardingScreen() {
    return const MaterialApp(
      home: OnboardingScreen(),
    );
  }

  group('OnboardingScreen', () {
    testWidgets('shows first slide on launch', (tester) async {
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      expect(find.text('Track expenses together'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('shows first slide subtitle', (tester) async {
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Share expenses with your partner and stay on top of your finances',
        ),
        findsOneWidget,
      );
    });

    testWidgets('navigates to second slide on Next tap', (tester) async {
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Set budgets, stay on track'), findsOneWidget);
    });

    testWidgets('shows Get Started on last slide', (tester) async {
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      // Go to slide 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Go to slide 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Privacy you control'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('does not show Get Started on first slide', (tester) async {
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsNothing);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}
