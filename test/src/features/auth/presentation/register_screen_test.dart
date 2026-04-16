import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/src/features/auth/presentation/register_screen.dart';
import 'package:moneymate/src/features/auth/presentation/auth_controller.dart';

void main() {
  Widget createRegisterScreen() {
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(() => AuthController()),
      ],
      child: const MaterialApp(
        home: RegisterScreen(),
      ),
    );
  }

  group('RegisterScreen', () {
    setUp(() {});

    testWidgets('renders all UI elements', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createRegisterScreen());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
    });

    testWidgets('shows already have account link', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createRegisterScreen());
      await tester.pumpAndSettle();

      expect(find.text('Already have an account? Sign In'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createRegisterScreen());
      await tester.pumpAndSettle();

      // Scroll down to find Create Account button
      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.text('Enter your name'), findsOneWidget);
    });
  });
}
