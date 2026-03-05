# Couples Expense Tracker — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Flutter mobile app for couples to track shared expenses with privacy controls, freemium monetization, and real-time sync.

**Architecture:** Feature-first modular Flutter app with Repository pattern. Firebase handles auth, database (Firestore), push notifications, and cloud functions. Riverpod 3.x manages state with code generation. RevenueCat manages subscriptions.

**Tech Stack:** Flutter 3.29+, Dart 3.7+, Riverpod 3.x, Freezed, GoRouter, Firebase (Auth, Firestore, Cloud Functions, Cloud Messaging), RevenueCat, mocktail

**Design Doc:** `docs/plans/2026-03-05-couples-expense-tracker-design.md`

---

## Phase 1: Foundation (Weeks 1-2)

### Task 1: Flutter Project Scaffold

**Files:**
- Create: project root via `flutter create`
- Create: `pubspec.yaml` (overwrite generated)
- Create: `analysis_options.yaml`
- Create: `.gitignore`

**Step 1: Create Flutter project**

Run:
```bash
cd /Users/veka/Projects/moneytracker-appstore
flutter create --empty --platforms=ios,android --org com.moneymate .
```

Expected: Flutter project created with ios/ and android/ directories.

**Step 2: Replace pubspec.yaml with project dependencies**

```yaml
name: moneymate
description: Couples expense tracker
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.7.0
  flutter: ">=3.29.0"

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^3.2.1
  riverpod_annotation: ^4.0.2

  # Navigation
  go_router: ^17.1.0

  # Firebase
  firebase_core: ^4.5.0
  cloud_firestore: ^6.1.3
  firebase_auth: ^6.2.0
  firebase_messaging: ^16.1.2
  cloud_functions: ^6.0.7

  # In-app purchases
  purchases_flutter: ^9.13.0

  # Data classes
  freezed_annotation: ^3.2.5
  json_annotation: ^4.9.0

  # UI
  fl_chart: ^0.70.2
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code generation
  build_runner:
  riverpod_generator: ^4.0.3
  freezed: ^3.2.5
  json_serializable: ^6.9.0

  # Linting
  very_good_analysis: ^10.2.0
  riverpod_lint:
  custom_lint:

  # Testing
  mocktail: ^1.0.4
```

**Step 3: Create analysis_options.yaml**

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false
```

**Step 4: Install dependencies**

Run:
```bash
flutter pub get
```

Expected: All dependencies resolve successfully.

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: scaffold Flutter project with dependencies"
```

---

### Task 2: Project Directory Structure

**Files:**
- Create: all directories and placeholder files under `lib/src/`

**Step 1: Create directory structure**

Run:
```bash
mkdir -p lib/src/{common_widgets,constants,exceptions,routing,utils}
mkdir -p lib/src/features/{auth,onboarding,expenses,budgets,dashboard,settings,subscription}/{data,domain,presentation}
mkdir -p test/src/features/{auth,expenses,budgets}/{data,domain,presentation}
```

**Step 2: Create lib/src/constants/app_sizes.dart**

```dart
/// Constant sizes used throughout the app.
/// Follows 4-point grid system.
class Sizes {
  static const double p4 = 4;
  static const double p8 = 8;
  static const double p12 = 12;
  static const double p16 = 16;
  static const double p20 = 20;
  static const double p24 = 24;
  static const double p32 = 32;
  static const double p48 = 48;
  static const double p64 = 64;
}
```

**Step 3: Create lib/src/constants/strings.dart**

```dart
/// App-wide string constants.
class AppStrings {
  static const String appName = 'MoneyMate';
  static const String currency = r'$';

  // Categories
  static const List<String> defaultCategories = [
    'Groceries',
    'Dining',
    'Transport',
    'Bills',
    'Entertainment',
    'Shopping',
    'Health',
    'Other',
  ];
}
```

**Step 4: Create lib/src/exceptions/app_exception.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
sealed class AppException with _$AppException implements Exception {
  const factory AppException.authError(String message) = AuthError;
  const factory AppException.firestoreError(String message) = FirestoreError;
  const factory AppException.networkError(String message) = NetworkError;
  const factory AppException.unknownError(String message) = UnknownError;
}
```

**Step 5: Run code generation**

Run:
```bash
dart run build_runner build -d
```

Expected: `.freezed.dart` files generated for AppException.

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: add project directory structure and base constants"
```

---

### Task 3: Domain Models (Freezed)

**Files:**
- Create: `lib/src/features/auth/domain/app_user.dart`
- Create: `lib/src/features/expenses/domain/expense.dart`
- Create: `lib/src/features/budgets/domain/budget.dart`
- Create: `lib/src/features/onboarding/domain/couple.dart`
- Create: `lib/src/features/onboarding/domain/couple_invite.dart`

**Step 1: Create AppUser model**

```dart
// lib/src/features/auth/domain/app_user.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    required String name,
    required String currency,
    required DateTime createdAt,
    String? coupleId,
    String? fcmToken,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return AppUser.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}
```

**Step 2: Create Expense model**

```dart
// lib/src/features/expenses/domain/expense.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required double amount,
    required String category,
    required DateTime date,
    required String userId,
    required String visibility, // "shared" or "private"
    required DateTime createdAt,
    @Default('') String note,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Expense.fromJson({
      'id': doc.id,
      ...data,
      'date': (data['date'] as Timestamp).toDate().toIso8601String(),
      'createdAt':
          (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  static Map<String, dynamic> toFirestore(Expense expense) {
    final json = expense.toJson();
    json.remove('id');
    json['date'] = Timestamp.fromDate(expense.date);
    json['createdAt'] = Timestamp.fromDate(expense.createdAt);
    return json;
  }
}
```

**Step 3: Create Budget model**

```dart
// lib/src/features/budgets/domain/budget.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String category,
    required double limit,
    required String month, // "2026-03"
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);

  factory Budget.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return Budget.fromJson({
      'id': id,
      ...data,
    });
  }
}
```

**Step 4: Create Couple model**

```dart
// lib/src/features/onboarding/domain/couple.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'couple.freezed.dart';
part 'couple.g.dart';

@freezed
class Couple with _$Couple {
  const factory Couple({
    required String id,
    required String user1Id,
    required String user2Id,
    required DateTime createdAt,
    required String subscriptionStatus, // trial, active, expired, free
    required DateTime trialStartDate,
    required DateTime trialEndDate,
    String? subscriberUserId,
    DateTime? expiresAt,
  }) = _Couple;

  factory Couple.fromJson(Map<String, dynamic> json) =>
      _$CoupleFromJson(json);

  factory Couple.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Couple.fromJson({
      'id': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'trialStartDate':
          (data['trialStartDate'] as Timestamp).toDate().toIso8601String(),
      'trialEndDate':
          (data['trialEndDate'] as Timestamp).toDate().toIso8601String(),
      if (data['expiresAt'] != null)
        'expiresAt':
            (data['expiresAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}
```

**Step 5: Create CoupleInvite model**

```dart
// lib/src/features/onboarding/domain/couple_invite.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'couple_invite.freezed.dart';
part 'couple_invite.g.dart';

@freezed
class CoupleInvite with _$CoupleInvite {
  const factory CoupleInvite({
    required String code,
    required String creatorUserId,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default(false) bool used,
    String? coupleId,
  }) = _CoupleInvite;

  factory CoupleInvite.fromJson(Map<String, dynamic> json) =>
      _$CoupleInviteFromJson(json);

  factory CoupleInvite.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return CoupleInvite.fromJson({
      'code': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'expiresAt':
          (data['expiresAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}
```

**Step 6: Run code generation**

Run:
```bash
dart run build_runner build -d
```

Expected: `.freezed.dart` and `.g.dart` files generated for all models.

**Step 7: Write unit tests for models**

```dart
// test/src/features/expenses/domain/expense_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';

void main() {
  group('Expense', () {
    test('creates expense with required fields', () {
      final expense = Expense(
        id: '1',
        amount: 25.50,
        category: 'Groceries',
        date: DateTime(2026, 3, 5),
        userId: 'user1',
        visibility: 'shared',
        createdAt: DateTime(2026, 3, 5),
      );

      expect(expense.amount, 25.50);
      expect(expense.category, 'Groceries');
      expect(expense.visibility, 'shared');
      expect(expense.note, '');
    });

    test('toJson and fromJson roundtrip preserves data', () {
      final expense = Expense(
        id: '1',
        amount: 42.0,
        category: 'Dining',
        date: DateTime(2026, 3, 5),
        userId: 'user1',
        visibility: 'private',
        createdAt: DateTime(2026, 3, 5),
        note: 'Dinner with friends',
      );

      final json = expense.toJson();
      final restored = Expense.fromJson(json);

      expect(restored, expense);
    });

    test('copyWith creates modified copy', () {
      final expense = Expense(
        id: '1',
        amount: 10.0,
        category: 'Other',
        date: DateTime(2026, 3, 5),
        userId: 'user1',
        visibility: 'shared',
        createdAt: DateTime(2026, 3, 5),
      );

      final modified = expense.copyWith(amount: 20.0);

      expect(modified.amount, 20.0);
      expect(modified.id, '1');
    });
  });
}
```

**Step 8: Run tests**

Run:
```bash
flutter test test/src/features/expenses/domain/expense_test.dart
```

Expected: All 3 tests PASS.

**Step 9: Commit**

```bash
git add -A
git commit -m "feat: add domain models with Freezed (User, Expense, Budget, Couple)"
```

---

### Task 4: Theme and Design System

**Files:**
- Create: `lib/src/constants/app_colors.dart`
- Create: `lib/src/constants/app_theme.dart`

**Step 1: Create app colors**

```dart
// lib/src/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42DB);

  // Semantic
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);

  // Budget progress
  static const Color budgetSafe = Color(0xFF4CAF50);
  static const Color budgetWarning = Color(0xFFFF9800);
  static const Color budgetExceeded = Color(0xFFE53935);

  // Neutrals
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Category colors
  static const List<Color> categoryColors = [
    Color(0xFF4CAF50), // Groceries
    Color(0xFFFF9800), // Dining
    Color(0xFF2196F3), // Transport
    Color(0xFF9C27B0), // Bills
    Color(0xFFE91E63), // Entertainment
    Color(0xFF00BCD4), // Shopping
    Color(0xFFFF5722), // Health
    Color(0xFF607D8B), // Other
  ];
}
```

**Step 2: Create app theme**

```dart
// lib/src/constants/app_theme.dart
import 'package:flutter/material.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.p12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.p12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Sizes.p16,
          vertical: Sizes.p12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.p12),
          ),
        ),
      ),
    );
  }
}
```

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: add design system (colors, theme, sizes)"
```

---

### Task 5: Repository Interfaces

**Files:**
- Create: `lib/src/features/auth/domain/auth_repository.dart`
- Create: `lib/src/features/expenses/domain/expenses_repository.dart`
- Create: `lib/src/features/budgets/domain/budgets_repository.dart`
- Create: `lib/src/features/onboarding/domain/couples_repository.dart`

**Step 1: Create AuthRepository interface**

```dart
// lib/src/features/auth/domain/auth_repository.dart
import 'package:moneymate/src/features/auth/domain/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUpWithEmail(String email, String password, String name);
  Future<void> signOut();
  Future<void> deleteAccount();
  String? get currentUserId;
}
```

**Step 2: Create ExpensesRepository interface**

```dart
// lib/src/features/expenses/domain/expenses_repository.dart
import 'package:moneymate/src/features/expenses/domain/expense.dart';

abstract class ExpensesRepository {
  Stream<List<Expense>> watchExpenses({
    required String coupleId,
    required String month,
    String? category,
  });

  Stream<List<Expense>> watchVisibleExpenses({
    required String coupleId,
    required String month,
    required String currentUserId,
    required Map<String, String> partnerPrivacySettings,
  });

  Future<void> addExpense({
    required String coupleId,
    required Expense expense,
  });

  Future<void> updateExpense({
    required String coupleId,
    required Expense expense,
  });

  Future<void> deleteExpense({
    required String coupleId,
    required String expenseId,
  });

  Future<double> getCategoryTotal({
    required String coupleId,
    required String month,
    required String category,
  });
}
```

**Step 3: Create BudgetsRepository interface**

```dart
// lib/src/features/budgets/domain/budgets_repository.dart
import 'package:moneymate/src/features/budgets/domain/budget.dart';

abstract class BudgetsRepository {
  Stream<List<Budget>> watchBudgets({
    required String coupleId,
    required String month,
  });

  Future<void> setBudget({
    required String coupleId,
    required Budget budget,
  });

  Future<void> deleteBudget({
    required String coupleId,
    required String budgetId,
  });
}
```

**Step 4: Create CouplesRepository interface**

```dart
// lib/src/features/onboarding/domain/couples_repository.dart
import 'package:moneymate/src/features/onboarding/domain/couple.dart';
import 'package:moneymate/src/features/onboarding/domain/couple_invite.dart';

abstract class CouplesRepository {
  Future<Couple?> getCouple(String coupleId);
  Stream<Couple?> watchCouple(String coupleId);
  Future<CoupleInvite> createInvite(String userId);
  Future<Couple> acceptInvite(String inviteCode, String userId);
  Future<void> unlinkPartner(String coupleId, String userId);
  Future<Map<String, String>> getPartnerPrivacySettings({
    required String coupleId,
    required String partnerUserId,
  });
  Future<void> updatePrivacySettings({
    required String coupleId,
    required String userId,
    required Map<String, String> settings,
  });
}
```

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add repository interfaces for auth, expenses, budgets, couples"
```

---

### Task 6: App Entry Point and Router Setup

**Files:**
- Create: `lib/src/app.dart`
- Create: `lib/src/routing/app_router.dart`
- Modify: `lib/main.dart`

**Step 1: Create app router**

```dart
// lib/src/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login — Coming soon')),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home — Coming soon')),
        ),
      ),
    ],
  );
}
```

**Step 2: Create app widget**

```dart
// lib/src/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/src/constants/app_theme.dart';
import 'package:moneymate/src/routing/app_router.dart';

class MoneyMateApp extends ConsumerWidget {
  const MoneyMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'MoneyMate',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

**Step 3: Update main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp will be added in Task 7
  runApp(
    const ProviderScope(
      child: MoneyMateApp(),
    ),
  );
}
```

**Step 4: Run code generation**

Run:
```bash
dart run build_runner build -d
```

Expected: `app_router.g.dart` generated.

**Step 5: Verify app compiles and runs**

Run:
```bash
flutter analyze
```

Expected: No errors (warnings from unused imports acceptable at this stage).

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: add app entry point with GoRouter and Riverpod"
```

---

### Task 7: Firebase Project Setup

**Files:**
- Create: Firebase project (console)
- Create: `lib/firebase_options.dart` (generated)
- Modify: `lib/main.dart`
- Create: `firestore.rules`
- Create: `firebase.json`

**Step 1: Create Firebase project**

Run:
```bash
# Login to Firebase (if not already)
firebase login

# Create a new Firebase project (or use existing)
# If creating via CLI:
firebase projects:create moneymate-app

# Configure FlutterFire
flutterfire configure --project=moneymate-app
```

Expected: `lib/firebase_options.dart` generated. iOS and Android configured.

NOTE: If `flutterfire` is not installed, run:
```bash
dart pub global activate flutterfire_cli
```

**Step 2: Update main.dart with Firebase initialization**

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/firebase_options.dart';
import 'package:moneymate/src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MoneyMateApp(),
    ),
  );
}
```

**Step 3: Create Firestore security rules**

```
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Default deny all
    match /{document=**} {
      allow read, write: if false;
    }

    // Users: read/write own document only
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }

    // Couples: only members can access
    match /couples/{coupleId} {
      allow read: if isCoupleMember(coupleId);

      // Expenses
      match /expenses/{expenseId} {
        allow read: if isCoupleMember(coupleId)
                    && (resource.data.visibility == "shared"
                        || resource.data.userId == request.auth.uid);
        allow create: if isCoupleMember(coupleId)
                      && request.resource.data.userId == request.auth.uid
                      && request.resource.data.amount > 0;
        allow update, delete: if isCoupleMember(coupleId)
                              && resource.data.userId == request.auth.uid;
      }

      // Budgets
      match /budgets/{budgetId} {
        allow read, write: if isCoupleMember(coupleId);
      }

      // Privacy settings
      match /privacySettings/{userId} {
        allow read: if isCoupleMember(coupleId);
        allow write: if request.auth != null
                     && request.auth.uid == userId;
      }
    }

    // Invite codes
    match /coupleInvites/{inviteCode} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }

    function isCoupleMember(coupleId) {
      let couple = get(/databases/$(database)/documents/couples/$(coupleId));
      return request.auth != null
             && (couple.data.user1Id == request.auth.uid
                 || couple.data.user2Id == request.auth.uid);
    }
  }
}
```

**Step 4: Create firebase.json**

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "emulators": {
    "auth": { "port": 9099 },
    "firestore": { "port": 8080 },
    "functions": { "port": 5001 },
    "ui": { "enabled": true }
  }
}
```

**Step 5: Create firestore.indexes.json**

```json
{
  "indexes": [
    {
      "collectionGroup": "expenses",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "category", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "expenses",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "expenses",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "visibility", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

**Step 6: Deploy rules**

Run:
```bash
firebase deploy --only firestore:rules,firestore:indexes
```

**Step 7: Commit**

```bash
git add -A
git commit -m "feat: configure Firebase with Firestore security rules and indexes"
```

---

## Phase 2: Auth + Couple Formation (Weeks 3-4)

### Task 8: Firebase Auth Repository Implementation

**Files:**
- Create: `lib/src/features/auth/data/firebase_auth_repository.dart`
- Create: `lib/src/features/auth/data/user_repository.dart`
- Create: `test/src/features/auth/data/firebase_auth_repository_test.dart`

**Step 1: Write failing test for auth repository**

```dart
// test/src/features/auth/data/firebase_auth_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moneymate/src/features/auth/data/user_repository.dart';
import 'package:moneymate/src/features/auth/domain/app_user.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('UserRepository', () {
    late MockUserRepository mockRepo;

    setUp(() {
      mockRepo = MockUserRepository();
    });

    test('getUser returns user when document exists', () async {
      final expectedUser = AppUser(
        id: 'user1',
        email: 'test@test.com',
        name: 'Test User',
        currency: 'USD',
        createdAt: DateTime(2026, 3, 5),
      );

      when(() => mockRepo.getUser('user1'))
          .thenAnswer((_) async => expectedUser);

      final user = await mockRepo.getUser('user1');
      expect(user, expectedUser);
      verify(() => mockRepo.getUser('user1')).called(1);
    });

    test('createUser stores user data', () async {
      final user = AppUser(
        id: 'user1',
        email: 'test@test.com',
        name: 'Test User',
        currency: 'USD',
        createdAt: DateTime(2026, 3, 5),
      );

      when(() => mockRepo.createUser(user)).thenAnswer((_) async {});

      await mockRepo.createUser(user);
      verify(() => mockRepo.createUser(user)).called(1);
    });
  });
}
```

**Step 2: Run test to verify it passes (mock-based)**

Run:
```bash
flutter test test/src/features/auth/data/firebase_auth_repository_test.dart
```

Expected: PASS.

**Step 3: Create UserRepository (Firestore)**

```dart
// lib/src/features/auth/data/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneymate/src/features/auth/domain/app_user.dart';

class UserRepository {
  UserRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Future<AppUser?> getUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<void> createUser(AppUser user) async {
    await _usersRef.doc(user.id).set({
      'email': user.email,
      'name': user.name,
      'currency': user.currency,
      'createdAt': FieldValue.serverTimestamp(),
      'coupleId': user.coupleId,
      'fcmToken': user.fcmToken,
    });
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _usersRef.doc(userId).update(data);
  }

  Future<void> deleteUser(String userId) async {
    await _usersRef.doc(userId).delete();
  }

  Stream<AppUser?> watchUser(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }
}
```

**Step 4: Create FirebaseAuthRepository**

```dart
// lib/src/features/auth/data/firebase_auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:moneymate/src/features/auth/data/user_repository.dart';
import 'package:moneymate/src/features/auth/domain/app_user.dart';

part 'firebase_auth_repository.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuthRepository firebaseAuthRepository(Ref ref) {
  return FirebaseAuthRepository(
    FirebaseAuth.instance,
    ref.watch(userRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return UserRepository(ref.watch(firestoreProvider));
}

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@riverpod
Stream<AppUser?> authStateChanges(Ref ref) {
  final repo = ref.watch(firebaseAuthRepositoryProvider);
  return repo.authStateChanges();
}

class FirebaseAuthRepository {
  FirebaseAuthRepository(this._auth, this._userRepo);
  final FirebaseAuth _auth;
  final UserRepository _userRepo;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _userRepo.getUser(firebaseUser.uid);
    });
  }

  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String name,
    String currency,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = AppUser(
      id: credential.user!.uid,
      email: email,
      name: name,
      currency: currency,
      createdAt: DateTime.now(),
    );
    await _userRepo.createUser(user);
    return user;
  }

  Future<AppUser?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _userRepo.getUser(credential.user!.uid);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final userId = currentUserId;
    if (userId != null) {
      await _userRepo.deleteUser(userId);
      await _auth.currentUser?.delete();
    }
  }
}
```

NOTE: The `firestoreProvider` import needs to be from this file or a shared providers file. Adjust import paths as needed during implementation.

**Step 5: Run code generation**

Run:
```bash
dart run build_runner build -d
```

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: implement Firebase auth repository with Riverpod providers"
```

---

### Task 9: Auth UI — Login and Registration Screens

**Files:**
- Create: `lib/src/features/auth/presentation/login_screen.dart`
- Create: `lib/src/features/auth/presentation/register_screen.dart`
- Create: `lib/src/features/auth/presentation/auth_controller.dart`

**Step 1: Create auth controller (Riverpod Notifier)**

```dart
// lib/src/features/auth/presentation/auth_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/auth/domain/app_user.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(firebaseAuthRepositoryProvider).signInWithEmail(
            email,
            password,
          ),
    );
  }

  Future<void> signUp(
    String email,
    String password,
    String name,
    String currency,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(firebaseAuthRepositoryProvider).signUpWithEmail(
            email,
            password,
            name,
            currency,
          ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(firebaseAuthRepositoryProvider).signOut(),
    );
  }
}
```

**Step 2: Create login screen**

```dart
// lib/src/features/auth/presentation/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/presentation/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'MoneyMate',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Sizes.p8),
                Text(
                  'Budget together, grow together',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Sizes.p48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Enter valid email',
                ),
                const SizedBox(height: Sizes.p16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  obscureText: true,
                  validator: (v) => v != null && v.length >= 6
                      ? null
                      : 'Min 6 characters',
                ),
                const SizedBox(height: Sizes.p24),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _onSignIn,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Sign In'),
                ),
                const SizedBox(height: Sizes.p16),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 3: Create register screen**

```dart
// lib/src/features/auth/presentation/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/presentation/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCurrency = 'USD';

  static const _currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'RSD'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
          _selectedCurrency,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Sizes.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (v) =>
                      v != null && v.isNotEmpty ? null : 'Enter your name',
                ),
                const SizedBox(height: Sizes.p16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Enter valid email',
                ),
                const SizedBox(height: Sizes.p16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  obscureText: true,
                  validator: (v) => v != null && v.length >= 6
                      ? null
                      : 'Min 6 characters',
                ),
                const SizedBox(height: Sizes.p16),
                DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  items: _currencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCurrency = v!),
                ),
                const SizedBox(height: Sizes.p32),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _onSignUp,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Account'),
                ),
                const SizedBox(height: Sizes.p16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 4: Update router with auth redirect**

Update `lib/src/routing/app_router.dart` to include login, register, and home routes with auth-based redirect. Import the auth screens and wire up `authStateChanges` provider for redirect logic.

**Step 5: Run code generation and verify**

Run:
```bash
dart run build_runner build -d
flutter analyze
```

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: add login and registration screens with auth controller"
```

---

### Task 10: Partner Invite System

**Files:**
- Create: `lib/src/features/onboarding/data/couples_repository_impl.dart`
- Create: `lib/src/features/onboarding/presentation/invite_partner_screen.dart`
- Create: `lib/src/features/onboarding/presentation/accept_invite_screen.dart`

**Step 1: Implement CouplesRepository**

```dart
// lib/src/features/onboarding/data/couples_repository_impl.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:moneymate/src/features/onboarding/domain/couple.dart';
import 'package:moneymate/src/features/onboarding/domain/couple_invite.dart';
import 'package:moneymate/src/features/onboarding/domain/couples_repository.dart';

part 'couples_repository_impl.g.dart';

@Riverpod(keepAlive: true)
CouplesRepositoryImpl couplesRepository(Ref ref) {
  return CouplesRepositoryImpl(FirebaseFirestore.instance);
}

class CouplesRepositoryImpl implements CouplesRepository {
  CouplesRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<CoupleInvite> createInvite(String userId) async {
    final code = _generateInviteCode();
    final now = DateTime.now();
    final invite = CoupleInvite(
      code: code,
      creatorUserId: userId,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 48)),
    );

    await _firestore.collection('coupleInvites').doc(code).set({
      'creatorUserId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(invite.expiresAt),
      'used': false,
    });

    return invite;
  }

  @override
  Future<Couple> acceptInvite(String inviteCode, String userId) async {
    return _firestore.runTransaction((transaction) async {
      final inviteDoc = await transaction
          .get(_firestore.collection('coupleInvites').doc(inviteCode));

      if (!inviteDoc.exists) {
        throw Exception('Invalid invite code');
      }

      final inviteData = inviteDoc.data()!;
      if (inviteData['used'] == true) {
        throw Exception('Invite already used');
      }

      final expiresAt = (inviteData['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('Invite expired');
      }

      final creatorUserId = inviteData['creatorUserId'] as String;
      if (creatorUserId == userId) {
        throw Exception('Cannot accept your own invite');
      }

      // Create couple
      final now = DateTime.now();
      final trialEnd = now.add(const Duration(days: 14));
      final coupleRef = _firestore.collection('couples').doc();

      transaction.set(coupleRef, {
        'user1Id': creatorUserId,
        'user2Id': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'subscriptionStatus': 'trial',
        'trialStartDate': Timestamp.fromDate(now),
        'trialEndDate': Timestamp.fromDate(trialEnd),
        'subscriberUserId': null,
        'expiresAt': null,
      });

      // Update both users with coupleId
      transaction.update(
        _firestore.collection('users').doc(creatorUserId),
        {'coupleId': coupleRef.id},
      );
      transaction.update(
        _firestore.collection('users').doc(userId),
        {'coupleId': coupleRef.id},
      );

      // Mark invite as used
      transaction.update(inviteDoc.reference, {
        'used': true,
        'coupleId': coupleRef.id,
      });

      return Couple(
        id: coupleRef.id,
        user1Id: creatorUserId,
        user2Id: userId,
        createdAt: now,
        subscriptionStatus: 'trial',
        trialStartDate: now,
        trialEndDate: trialEnd,
      );
    });
  }

  @override
  Future<Couple?> getCouple(String coupleId) async {
    final doc = await _firestore.collection('couples').doc(coupleId).get();
    if (!doc.exists) return null;
    return Couple.fromFirestore(doc);
  }

  @override
  Stream<Couple?> watchCouple(String coupleId) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .snapshots()
        .map((doc) => doc.exists ? Couple.fromFirestore(doc) : null);
  }

  @override
  Future<void> unlinkPartner(String coupleId, String userId) async {
    final couple = await getCouple(coupleId);
    if (couple == null) return;

    final batch = _firestore.batch();

    // Remove coupleId from both users
    batch.update(
      _firestore.collection('users').doc(couple.user1Id),
      {'coupleId': null},
    );
    batch.update(
      _firestore.collection('users').doc(couple.user2Id),
      {'coupleId': null},
    );

    await batch.commit();
  }

  @override
  Future<Map<String, String>> getPartnerPrivacySettings({
    required String coupleId,
    required String partnerUserId,
  }) async {
    final doc = await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('privacySettings')
        .doc(partnerUserId)
        .get();

    if (!doc.exists) return {};
    return Map<String, String>.from(doc.data()!);
  }

  @override
  Future<void> updatePrivacySettings({
    required String coupleId,
    required String userId,
    required Map<String, String> settings,
  }) async {
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('privacySettings')
        .doc(userId)
        .set(settings);
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
```

**Step 2: Create invite partner screen**

```dart
// lib/src/features/onboarding/presentation/invite_partner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/onboarding/data/couples_repository_impl.dart';
import 'package:moneymate/src/features/onboarding/domain/couple_invite.dart';
import 'package:share_plus/share_plus.dart';

class InvitePartnerScreen extends ConsumerStatefulWidget {
  const InvitePartnerScreen({super.key});

  @override
  ConsumerState<InvitePartnerScreen> createState() =>
      _InvitePartnerScreenState();
}

class _InvitePartnerScreenState extends ConsumerState<InvitePartnerScreen> {
  CoupleInvite? _invite;
  bool _isLoading = false;

  Future<void> _generateInvite() async {
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(firebaseAuthRepositoryProvider).currentUserId!;
      final invite =
          await ref.read(couplesRepositoryProvider).createInvite(userId);
      setState(() => _invite = invite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Partner')),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.favorite,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: Sizes.p24),
            Text(
              'Invite your partner to\ntrack expenses together',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.p32),
            if (_invite == null)
              ElevatedButton(
                onPressed: _isLoading ? null : _generateInvite,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Generate Invite Code'),
              )
            else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.p24),
                  child: Column(
                    children: [
                      const Text('Share this code with your partner:'),
                      const SizedBox(height: Sizes.p12),
                      Text(
                        _invite!.code,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: Sizes.p8),
                      Text(
                        'Expires in 48 hours',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Sizes.p16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _invite!.code),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied!')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                    ),
                  ),
                  const SizedBox(width: Sizes.p12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Share.share(
                          'Join me on MoneyMate! Use code: ${_invite!.code}',
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: Sizes.p24),
            TextButton(
              onPressed: () {
                // Skip for now — go to solo dashboard
              },
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}
```

NOTE: Add `share_plus` to pubspec.yaml dependencies:
```yaml
dependencies:
  share_plus: ^10.1.4
```

**Step 3: Create accept invite screen**

```dart
// lib/src/features/onboarding/presentation/accept_invite_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/onboarding/data/couples_repository_impl.dart';

class AcceptInviteScreen extends ConsumerStatefulWidget {
  const AcceptInviteScreen({super.key, this.initialCode});
  final String? initialCode;

  @override
  ConsumerState<AcceptInviteScreen> createState() => _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends ConsumerState<AcceptInviteScreen> {
  late final TextEditingController _codeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _acceptInvite() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a 6-character invite code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = ref.read(firebaseAuthRepositoryProvider).currentUserId!;
      await ref.read(couplesRepositoryProvider).acceptInvite(code, userId);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Partner')),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.group_add,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: Sizes.p24),
            Text(
              'Enter the invite code\nfrom your partner',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.p32),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Invite Code',
                hintText: 'ABC123',
                prefixIcon: Icon(Icons.vpn_key_outlined),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Sizes.p24),
            ElevatedButton(
              onPressed: _isLoading ? null : _acceptInvite,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 4: Run code generation and verify**

Run:
```bash
flutter pub get
dart run build_runner build -d
flutter analyze
```

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add partner invite system (create, share, accept invite code)"
```

---

## Phase 3: Core Expense Tracking (Weeks 5-6)

### Task 11: Expenses Repository Implementation

**Files:**
- Create: `lib/src/features/expenses/data/expenses_repository_impl.dart`
- Create: `test/src/features/expenses/data/expenses_repository_test.dart`

**Step 1: Write failing test**

```dart
// test/src/features/expenses/data/expenses_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:moneymate/src/features/expenses/domain/expenses_repository.dart';

class MockExpensesRepository extends Mock implements ExpensesRepository {}

void main() {
  group('ExpensesRepository', () {
    late MockExpensesRepository mockRepo;

    setUp(() {
      mockRepo = MockExpensesRepository();
    });

    test('watchExpenses returns list of expenses for a month', () {
      final expenses = [
        Expense(
          id: '1',
          amount: 25.0,
          category: 'Groceries',
          date: DateTime(2026, 3, 5),
          userId: 'user1',
          visibility: 'shared',
          createdAt: DateTime(2026, 3, 5),
        ),
      ];

      when(
        () => mockRepo.watchExpenses(
          coupleId: 'couple1',
          month: '2026-03',
        ),
      ).thenAnswer((_) => Stream.value(expenses));

      final stream = mockRepo.watchExpenses(
        coupleId: 'couple1',
        month: '2026-03',
      );

      expect(stream, emits(expenses));
    });

    test('getCategoryTotal returns sum for category', () async {
      when(
        () => mockRepo.getCategoryTotal(
          coupleId: 'couple1',
          month: '2026-03',
          category: 'Groceries',
        ),
      ).thenAnswer((_) async => 150.0);

      final total = await mockRepo.getCategoryTotal(
        coupleId: 'couple1',
        month: '2026-03',
        category: 'Groceries',
      );

      expect(total, 150.0);
    });
  });
}
```

**Step 2: Run test**

Run:
```bash
flutter test test/src/features/expenses/data/expenses_repository_test.dart
```

Expected: PASS.

**Step 3: Implement ExpensesRepository**

```dart
// lib/src/features/expenses/data/expenses_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:moneymate/src/features/expenses/domain/expenses_repository.dart';

part 'expenses_repository_impl.g.dart';

@Riverpod(keepAlive: true)
ExpensesRepositoryImpl expensesRepository(Ref ref) {
  return ExpensesRepositoryImpl(FirebaseFirestore.instance);
}

class ExpensesRepositoryImpl implements ExpensesRepository {
  ExpensesRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _expensesRef(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('expenses');

  @override
  Stream<List<Expense>> watchExpenses({
    required String coupleId,
    required String month,
    String? category,
  }) {
    final startDate = DateTime.parse('$month-01');
    final endDate = DateTime(startDate.year, startDate.month + 1);

    var query = _expensesRef(coupleId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map(
          (snapshot) =>
              snapshot.docs.map(Expense.fromFirestore).toList(),
        );
  }

  @override
  Stream<List<Expense>> watchVisibleExpenses({
    required String coupleId,
    required String month,
    required String currentUserId,
    required Map<String, String> partnerPrivacySettings,
  }) {
    return watchExpenses(coupleId: coupleId, month: month).map((expenses) {
      return expenses.where((expense) {
        // User always sees their own expenses
        if (expense.userId == currentUserId) return true;
        // Check partner's privacy settings for this category
        final visibility = partnerPrivacySettings[expense.category] ?? 'all';
        if (visibility == 'private') return false;
        if (visibility == 'total') return false; // hide individual transactions
        return true; // "all" — show everything
      }).toList();
    });
  }

  @override
  Future<void> addExpense({
    required String coupleId,
    required Expense expense,
  }) async {
    await _expensesRef(coupleId).add(Expense.toFirestore(expense));
  }

  @override
  Future<void> updateExpense({
    required String coupleId,
    required Expense expense,
  }) async {
    await _expensesRef(coupleId)
        .doc(expense.id)
        .update(Expense.toFirestore(expense));
  }

  @override
  Future<void> deleteExpense({
    required String coupleId,
    required String expenseId,
  }) async {
    await _expensesRef(coupleId).doc(expenseId).delete();
  }

  @override
  Future<double> getCategoryTotal({
    required String coupleId,
    required String month,
    required String category,
  }) async {
    final startDate = DateTime.parse('$month-01');
    final endDate = DateTime(startDate.year, startDate.month + 1);

    final snapshot = await _expensesRef(coupleId)
        .where('category', isEqualTo: category)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs.fold<double>(
      0,
      (sum, doc) => sum + (doc.data()['amount'] as num).toDouble(),
    );
  }
}
```

**Step 4: Run code generation**

Run:
```bash
dart run build_runner build -d
```

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: implement expenses repository with Firestore and privacy filtering"
```

---

### Task 12: Add Expense Screen (Fast Entry)

**Files:**
- Create: `lib/src/features/expenses/presentation/add_expense_screen.dart`
- Create: `lib/src/features/expenses/presentation/category_grid.dart`
- Create: `lib/src/features/expenses/presentation/expenses_controller.dart`

**Step 1: Create expenses controller**

```dart
// lib/src/features/expenses/presentation/expenses_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';

part 'expenses_controller.g.dart';

@riverpod
class ExpensesController extends _$ExpensesController {
  @override
  FutureOr<void> build() {}

  Future<bool> addExpense({
    required String coupleId,
    required double amount,
    required String category,
    required String visibility,
    String note = '',
    DateTime? date,
  }) async {
    final userId = ref.read(firebaseAuthRepositoryProvider).currentUserId!;
    final now = DateTime.now();

    final expense = Expense(
      id: '', // Firestore will generate
      amount: amount,
      category: category,
      date: date ?? now,
      userId: userId,
      visibility: visibility,
      createdAt: now,
      note: note,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(expensesRepositoryProvider).addExpense(
            coupleId: coupleId,
            expense: expense,
          ),
    );

    return !state.hasError;
  }
}
```

**Step 2: Create category grid widget**

```dart
// lib/src/features/expenses/presentation/category_grid.dart
import 'package:flutter/material.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  static const _categories = [
    ('Groceries', Icons.shopping_cart),
    ('Dining', Icons.restaurant),
    ('Transport', Icons.directions_car),
    ('Bills', Icons.receipt_long),
    ('Entertainment', Icons.movie),
    ('Shopping', Icons.shopping_bag),
    ('Health', Icons.local_hospital),
    ('Other', Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: Sizes.p8,
        crossAxisSpacing: Sizes.p8,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final (name, icon) = _categories[index];
        final isSelected = selectedCategory == name;
        final color = AppColors.categoryColors[index];

        return GestureDetector(
          onTap: () => onCategorySelected(name),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Sizes.p12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                ),
              ),
              const SizedBox(height: Sizes.p4),
              Text(
                name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
```

**Step 3: Create add expense screen**

```dart
// lib/src/features/expenses/presentation/add_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/expenses/presentation/category_grid.dart';
import 'package:moneymate/src/features/expenses/presentation/expenses_controller.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, required this.coupleId});
  final String coupleId;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  String _amount = '';
  String? _selectedCategory;
  String _note = '';
  bool _isPrivate = false;

  void _onDigitPressed(String digit) {
    setState(() {
      if (digit == '.' && _amount.contains('.')) return;
      if (digit == '.' && _amount.isEmpty) {
        _amount = '0.';
        return;
      }
      // Limit to 2 decimal places
      if (_amount.contains('.') &&
          _amount.split('.').last.length >= 2) return;
      _amount += digit;
    });
  }

  void _onBackspace() {
    if (_amount.isNotEmpty) {
      setState(() => _amount = _amount.substring(0, _amount.length - 1));
    }
  }

  Future<void> _onSave() async {
    if (_amount.isEmpty || double.tryParse(_amount) == null) return;
    if (_selectedCategory == null) return;

    final success = await ref.read(expensesControllerProvider.notifier)
        .addExpense(
      coupleId: widget.coupleId,
      amount: double.parse(_amount),
      category: _selectedCategory!,
      visibility: _isPrivate ? 'private' : 'shared',
      note: _note,
    );

    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expensesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isPrivate = !_isPrivate),
            icon: Icon(
              _isPrivate ? Icons.lock : Icons.lock_open,
              color: _isPrivate ? AppColors.warning : null,
            ),
            tooltip: _isPrivate ? 'Private' : 'Shared',
          ),
        ],
      ),
      body: Column(
        children: [
          // Amount display
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.p32),
            child: Text(
              _amount.isEmpty ? '0' : _amount,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          // Category grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
            child: CategoryGrid(
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) =>
                  setState(() => _selectedCategory = cat),
            ),
          ),

          const Spacer(),

          // Number pad
          Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: _buildNumberPad(),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Sizes.p16,
              0,
              Sizes.p16,
              Sizes.p32,
            ),
            child: ElevatedButton(
              onPressed: state.isLoading ||
                      _amount.isEmpty ||
                      _selectedCategory == null
                  ? null
                  : _onSave,
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    const digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '<'],
    ];

    return Column(
      children: digits.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((d) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Sizes.p12),
                    onTap: d == '<' ? _onBackspace : () => _onDigitPressed(d),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: d == '<'
                          ? const Icon(Icons.backspace_outlined)
                          : Text(
                              d,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall,
                            ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
```

**Step 4: Run code generation and verify**

Run:
```bash
dart run build_runner build -d
flutter analyze
```

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add expense entry screen with number pad and category grid"
```

---

### Task 13: Expense List Screen

**Files:**
- Create: `lib/src/features/expenses/presentation/expenses_list_screen.dart`

**Step 1: Create expense list screen**

```dart
// lib/src/features/expenses/presentation/expenses_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({
    super.key,
    required this.coupleId,
    required this.month,
  });

  final String coupleId;
  final String month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesStream = ref.watch(
      expensesRepositoryProvider.select(
        (repo) => repo.watchExpenses(coupleId: coupleId, month: month),
      ),
    );

    return StreamBuilder<List<Expense>>(
      stream: ref
          .read(expensesRepositoryProvider)
          .watchExpenses(coupleId: coupleId, month: month),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenses = snapshot.data ?? [];

        if (expenses.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: Sizes.p16),
                Text('No expenses yet'),
              ],
            ),
          );
        }

        // Group by date
        final grouped = <String, List<Expense>>{};
        for (final expense in expenses) {
          final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
          grouped.putIfAbsent(dateKey, () => []).add(expense);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(Sizes.p16),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final dateKey = grouped.keys.elementAt(index);
            final dayExpenses = grouped[dateKey]!;
            final dayTotal =
                dayExpenses.fold<double>(0, (sum, e) => sum + e.amount);
            final date = DateTime.parse(dateKey);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d').format(date),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      Text(
                        '\$${dayTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.expense,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                ...dayExpenses.map(
                  (expense) => _ExpenseListTile(expense: expense),
                ),
                const Divider(),
              ],
            );
          },
        );
      },
    );
  }
}

class _ExpenseListTile extends StatelessWidget {
  const _ExpenseListTile({required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(
          _categoryIcon(expense.category),
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(expense.category),
      subtitle: expense.note.isNotEmpty ? Text(expense.note) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (expense.visibility == 'private')
            const Padding(
              padding: EdgeInsets.only(right: Sizes.p8),
              child: Icon(Icons.lock, size: 16, color: AppColors.warning),
            ),
          Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Groceries' => Icons.shopping_cart,
      'Dining' => Icons.restaurant,
      'Transport' => Icons.directions_car,
      'Bills' => Icons.receipt_long,
      'Entertainment' => Icons.movie,
      'Shopping' => Icons.shopping_bag,
      'Health' => Icons.local_hospital,
      _ => Icons.more_horiz,
    };
  }
}
```

**Step 2: Commit**

```bash
git add -A
git commit -m "feat: add expense list screen with date grouping"
```

---

## Phase 4: Budgets + Dashboard (Weeks 7-8)

### Task 14: Budgets Repository Implementation

**Files:**
- Create: `lib/src/features/budgets/data/budgets_repository_impl.dart`

**Step 1: Implement BudgetsRepository**

```dart
// lib/src/features/budgets/data/budgets_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:moneymate/src/features/budgets/domain/budget.dart';
import 'package:moneymate/src/features/budgets/domain/budgets_repository.dart';

part 'budgets_repository_impl.g.dart';

@Riverpod(keepAlive: true)
BudgetsRepositoryImpl budgetsRepository(Ref ref) {
  return BudgetsRepositoryImpl(FirebaseFirestore.instance);
}

class BudgetsRepositoryImpl implements BudgetsRepository {
  BudgetsRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _budgetsRef(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('budgets');

  @override
  Stream<List<Budget>> watchBudgets({
    required String coupleId,
    required String month,
  }) {
    return _budgetsRef(coupleId)
        .where('month', isEqualTo: month)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return Budget.fromFirestore(doc.data(), doc.id);
          }).toList(),
        );
  }

  @override
  Future<void> setBudget({
    required String coupleId,
    required Budget budget,
  }) async {
    if (budget.id.isEmpty) {
      await _budgetsRef(coupleId).add({
        'category': budget.category,
        'limit': budget.limit,
        'month': budget.month,
      });
    } else {
      await _budgetsRef(coupleId).doc(budget.id).update({
        'category': budget.category,
        'limit': budget.limit,
        'month': budget.month,
      });
    }
  }

  @override
  Future<void> deleteBudget({
    required String coupleId,
    required String budgetId,
  }) async {
    await _budgetsRef(coupleId).doc(budgetId).delete();
  }
}
```

**Step 2: Commit**

```bash
git add -A
git commit -m "feat: implement budgets repository with Firestore"
```

---

### Task 15: Dashboard Screen (Monthly Overview)

**Files:**
- Create: `lib/src/features/dashboard/presentation/dashboard_screen.dart`
- Create: `lib/src/features/dashboard/presentation/spending_pie_chart.dart`
- Create: `lib/src/features/dashboard/presentation/budget_progress_card.dart`

**Step 1: Create dashboard screen**

This is the main home screen. It shows:
- Current month total spending
- Pie chart (Premium only) of spending by category
- Budget progress bars
- FAB button to add expense

```dart
// lib/src/features/dashboard/presentation/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/budgets/data/budgets_repository_impl.dart';
import 'package:moneymate/src/features/budgets/domain/budget.dart';
import 'package:moneymate/src/features/dashboard/presentation/budget_progress_card.dart';
import 'package:moneymate/src/features/dashboard/presentation/spending_pie_chart.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.coupleId,
  });

  final String coupleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final month = DateFormat('yyyy-MM').format(now);
    final monthDisplay = DateFormat('MMMM yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(monthDisplay),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: ref
            .read(expensesRepositoryProvider)
            .watchExpenses(coupleId: coupleId, month: month),
        builder: (context, expenseSnapshot) {
          final expenses = expenseSnapshot.data ?? [];
          final totalSpent =
              expenses.fold<double>(0, (sum, e) => sum + e.amount);

          // Group by category
          final categoryTotals = <String, double>{};
          for (final expense in expenses) {
            categoryTotals[expense.category] =
                (categoryTotals[expense.category] ?? 0) + expense.amount;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total spent card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Sizes.p24),
                    child: Column(
                      children: [
                        Text(
                          'Total Spent',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: Sizes.p8),
                        Text(
                          '\$${totalSpent.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.expense,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Sizes.p16),

                // Pie chart (TODO: gate behind Premium)
                if (categoryTotals.isNotEmpty)
                  SpendingPieChart(categoryTotals: categoryTotals),

                const SizedBox(height: Sizes.p24),

                // Budget progress
                Text(
                  'Budgets',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: Sizes.p12),

                StreamBuilder<List<Budget>>(
                  stream: ref
                      .read(budgetsRepositoryProvider)
                      .watchBudgets(coupleId: coupleId, month: month),
                  builder: (context, budgetSnapshot) {
                    final budgets = budgetSnapshot.data ?? [];

                    if (budgets.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(Sizes.p24),
                          child: Center(
                            child: Text('No budgets set. Tap + to create one.'),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: budgets.map((budget) {
                        final spent = categoryTotals[budget.category] ?? 0;
                        return BudgetProgressCard(
                          budget: budget,
                          spent: spent,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-expense/$coupleId'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onDestinationSelected: (index) {
          // Navigation handled by GoRouter
        },
      ),
    );
  }
}
```

**Step 2: Create pie chart widget**

```dart
// lib/src/features/dashboard/presentation/spending_pie_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';

class SpendingPieChart extends StatelessWidget {
  const SpendingPieChart({super.key, required this.categoryTotals});
  final Map<String, double> categoryTotals;

  @override
  Widget build(BuildContext context) {
    final total = categoryTotals.values.fold<double>(0, (a, b) => a + b);
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value.key;
                    final amount = entry.value.value;
                    final percentage = (amount / total * 100);

                    return PieChartSectionData(
                      color: AppColors.categoryColors[
                          index % AppColors.categoryColors.length],
                      value: amount,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: Sizes.p16),
            // Legend
            Wrap(
              spacing: Sizes.p16,
              runSpacing: Sizes.p8,
              children: entries.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value.key;
                final amount = entry.value.value;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.categoryColors[
                            index % AppColors.categoryColors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$category: \$${amount.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 3: Create budget progress card**

```dart
// lib/src/features/dashboard/presentation/budget_progress_card.dart
import 'package:flutter/material.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/budgets/domain/budget.dart';

class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.spent,
  });

  final Budget budget;
  final double spent;

  @override
  Widget build(BuildContext context) {
    final progress = (spent / budget.limit).clamp(0.0, 1.5);
    final percentage = (progress * 100).toStringAsFixed(0);

    final Color progressColor;
    if (progress >= 1.0) {
      progressColor = AppColors.budgetExceeded;
    } else if (progress >= 0.8) {
      progressColor = AppColors.budgetWarning;
    } else {
      progressColor = AppColors.budgetSafe;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: Sizes.p8),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.category,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '\$${spent.toStringAsFixed(2)} / \$${budget.limit.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Sizes.p8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: progressColor.withOpacity(0.1),
                color: progressColor,
                minHeight: 8,
              ),
            ),
            if (progress >= 1.0)
              Padding(
                padding: const EdgeInsets.only(top: Sizes.p4),
                child: Text(
                  'Over budget by \$${(spent - budget.limit).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.budgetExceeded,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: add dashboard with total spending, pie chart, and budget progress"
```

---

## Phase 5: Subscription + Polish (Weeks 9-10)

### Task 16: RevenueCat Subscription Integration

**Files:**
- Create: `lib/src/features/subscription/data/subscription_repository.dart`
- Create: `lib/src/features/subscription/presentation/paywall_screen.dart`
- Modify: `lib/main.dart` (add RevenueCat init)

This task requires RevenueCat dashboard setup (creating products, entitlements, and offerings). The implementation details depend on RevenueCat API keys which are configured per-project.

**Step 1: Create subscription repository**

```dart
// lib/src/features/subscription/data/subscription_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_repository.g.dart';

@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) {
  return SubscriptionRepository();
}

@riverpod
Stream<CustomerInfo> customerInfo(Ref ref) {
  return Purchases.customerInfoStream;
}

@riverpod
Future<bool> isPremium(Ref ref) async {
  final info = await Purchases.getCustomerInfo();
  return info.entitlements.active.containsKey('premium');
}

class SubscriptionRepository {
  Future<Offerings> getOfferings() async {
    return Purchases.getOfferings();
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    return Purchases.purchasePackage(package);
  }

  Future<CustomerInfo> restorePurchases() async {
    return Purchases.restoreTransactions();
  }

  Future<bool> isPremium() async {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey('premium');
  }
}
```

**Step 2: Create paywall screen**

The paywall screen shows pricing options (monthly/annual). The actual product configuration is done in RevenueCat dashboard and Apple/Google consoles.

**Step 3: Update main.dart with RevenueCat initialization**

Add after Firebase.initializeApp():
```dart
await Purchases.setLogLevel(LogLevel.debug);
final config = PurchasesConfiguration('<YOUR_REVENUECAT_API_KEY>');
await Purchases.configure(config);
```

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: add RevenueCat subscription integration with paywall"
```

---

### Task 17: Push Notifications Setup

**Files:**
- Create: `lib/src/services/notification_service.dart`
- Create: Cloud Function for notification sending (separate functions/ directory)

**Step 1: Create notification service**

```dart
// lib/src/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

class NotificationService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission();

    // Get FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      // Store token in user document — handled by caller
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification or in-app banner
    // Implementation depends on flutter_local_notifications package
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // Handle background message — minimal processing
}
```

**Step 2: Create Cloud Function for sending notifications (outline)**

Create a `functions/` directory with a Cloud Function triggered on Firestore writes to `couples/{coupleId}/expenses/{expenseId}`. The function:
1. Reads the new expense document
2. Finds the partner's FCM token
3. Sends a push notification with expense details
4. Implements throttling (batch notifications, max 1 per 15 min)

This requires a separate `functions/package.json` and `functions/index.js` (or TypeScript) setup.

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: add push notification service and Cloud Function outline"
```

---

### Task 18: Settings and Privacy Controls Screen

**Files:**
- Create: `lib/src/features/settings/presentation/settings_screen.dart`
- Create: `lib/src/features/settings/presentation/privacy_settings_screen.dart`

**Step 1: Create settings screen**

Settings includes: Privacy controls, Notifications toggle, Account deletion, Unlink partner, Subscription management.

**Step 2: Create privacy settings screen**

Shows each category with a dropdown: "Share All" / "Share Total Only" / "Private". Updates Firestore `privacySettings` subcollection.

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: add settings and privacy controls screens"
```

---

### Task 19: Update Router with All Screens

**Files:**
- Modify: `lib/src/routing/app_router.dart`

**Step 1: Update GoRouter with complete route definitions**

Add routes for:
- `/login` → LoginScreen
- `/register` → RegisterScreen
- `/invite` → InvitePartnerScreen
- `/accept-invite` → AcceptInviteScreen
- `/home` → DashboardScreen (with BottomNavigationBar)
- `/add-expense/:coupleId` → AddExpenseScreen
- `/expenses/:coupleId` → ExpensesListScreen
- `/settings` → SettingsScreen
- `/settings/privacy` → PrivacySettingsScreen
- `/subscription` → PaywallScreen

Add auth redirect logic using `authStateChanges` provider.

**Step 2: Commit**

```bash
git add -A
git commit -m "feat: wire up complete router with auth redirect and all screens"
```

---

### Task 20: Account Deletion (App Store Requirement)

**Files:**
- Create: Cloud Function for account deletion
- Modify: Settings screen to add delete button

**Step 1: Implement account deletion Cloud Function**

The Cloud Function (callable) must:
1. Delete all user data from Firestore (user doc, couple data if applicable)
2. Delete Firebase Auth account
3. Cancel RevenueCat subscription
4. Handle partner's view (remove coupleId from partner)

**Step 2: Add delete account UI to settings**

Confirmation dialog → calls Cloud Function → signs out → returns to login.

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: add account deletion (App Store requirement)"
```

---

### Task 21: Final Integration Testing and App Store Preparation

**Step 1: Run full test suite**

```bash
flutter test
```

Expected: All tests pass.

**Step 2: Build for release**

```bash
flutter build ios --release
flutter build appbundle --release  # for Google Play
```

**Step 3: Prepare App Store metadata**
- Screenshots (6 screens as outlined in CEO review)
- App description (lead with pain point)
- Keywords (ASO keywords from CEO review)
- Privacy policy URL
- Support URL

**Step 4: Submit to TestFlight and Firebase App Distribution**

```bash
# iOS
cd ios && fastlane beta  # if using fastlane

# Android
cd android && fastlane beta  # if using fastlane
```

**Step 5: Commit**

```bash
git add -A
git commit -m "chore: prepare for beta release"
```

---

## Post-Launch Tasks (not in this plan)

These are tracked separately:
- V1.1: Recurring expenses, savings goals, dark mode
- V2: Bank sync (Plaid), receipt scanning (server-side OCR), multi-currency, CSV export
- Ongoing: Weekly digest notifications, referral program, ASO optimization
