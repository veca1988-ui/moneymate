# MoneyMate V1.0 Completion Design

## Goal

Complete all features needed for a fully functional freemium couples expense tracker, then publish to App Store and Play Store.

## Target

- Platforms: iOS + Android (both stores)
- Language: English UI, multi-currency support (USD, EUR, GBP, CAD, AUD, RSD)
- Model: Freemium (free tier with limits, premium via RevenueCat)
- Post-launch (V1.1): Google/Apple Sign-In, recurring expenses, savings goals

---

## Faza 1: Finish Core Features

### 1.1 Currency Display

**Problem:** App always shows `$` regardless of user's selected currency.

**Solution:**
- Create a currency helper that maps currency code to symbol: USD → $, EUR → €, GBP → £, RSD → RSD, CAD → C$, AUD → A$
- Read `AppUser.currency` and apply the correct symbol everywhere: dashboard total, expense list, budget cards, pie chart, add expense screen
- Format numbers with appropriate decimal places (RSD typically no decimals, others 2)

### 1.2 Edit/Delete Expenses

**Problem:** Repository supports update/delete but no UI exposes it.

**Solution:**
- `ExpensesListScreen`: add `Dismissible` widget on each expense tile
  - Swipe left → red Delete background with confirmation dialog
  - Tap on expense → opens `AddExpenseScreen` in edit mode
- `AddExpenseScreen` changes:
  - Accept optional `Expense` parameter for edit mode
  - Pre-populate fields when editing
  - Title changes to "Edit Expense"
  - Save button calls `updateExpense` instead of `addExpense`

### 1.3 Date Picker for Expenses

**Problem:** Expenses always recorded with today's date. Users often enter past expenses.

**Solution:**
- Add a date row in `AddExpenseScreen` showing the selected date (default: today)
- Tapping it opens `showDatePicker` with range: 1 year ago to today
- Selected date is passed to `addExpense` / `updateExpense`

### 1.4 Note Field + User Name in Expense List

**Problem:** Expense model supports `note` field but no UI input. In couples mode, no way to see who added the expense.

**Solution:**
- `AddExpenseScreen`: add optional text field below the category grid, labeled "Note (optional)"
- `ExpensesListScreen` tile changes:
  - Show note text (if present) below amount in smaller gray text
  - Show user's name next to the date/time (fetch from user doc or embed name in expense at creation time)
  - For solo mode, skip the name display

**Design decision:** Embed `userName` in the expense document at creation time rather than fetching from users collection on every render. Denormalized but much simpler and faster.

### 1.5 Reports Tab

**Problem:** Reports navigation tab is a no-op placeholder.

**Solution:**
- New `ReportsScreen` accessible from bottom navigation tab (index 2)
- Content for selected month:
  - Total spent (top card)
  - Category breakdown: list of categories with amount and percentage bar
  - Month selector (left/right arrows to navigate between months)
- Route: `/reports/:coupleId` — `coupleId` passed from DashboardScreen's bottom navigation (same pattern as Expenses tab)
- Free users see current month only; premium users can navigate to any past month
- In Faza 2, add "Upgrade" prompt when free users try to view past months

### 1.6 Unlink Partner

**Problem:** Settings dialog confirms but doesn't call the existing `unlinkPartner()` method.

**Solution:**
- `SettingsScreen` needs access to `coupleId` — read it from `authStateChangesProvider` (`user.coupleId`)
- Wire the Unlink Partner confirmation dialog to call `couplesRepository.unlinkPartner(coupleId, userId)`
- After unlinking, invalidate `authStateChangesProvider` to refresh router
- User returns to solo mode (InvitePartnerScreen)
- Show success snackbar: "Partner unlinked successfully"
- If user has no partner (solo mode), hide the "Unlink Partner" option entirely

---

## Faza 2: Monetization

### 2.1 Free Tier Limits

**Problem:** No feature gating — all features available to everyone.

**Solution:**
- Free tier limits:
  - 50 expenses per month (enough for a couple's typical usage)
  - All 8 categories available to everyone
  - Basic Reports (category breakdown for current month only)
  - Premium unlocks: unlimited expenses, full Reports history (all months), custom categories, CSV export, budget alerts
- Track expense count per month in the existing expenses stream
- When user tries to add expense #51 → show paywall
- `isPremium` check reads from local subscription state (RevenueCat when available, fallback to Firestore `subscriptionStatus`)

### 2.2 Paywall Trigger

**Problem:** Paywall exists but is never triggered contextually.

**Solution:**
- Show paywall when:
  - User hits 50 expense limit for the month
  - User tries to view Reports history (months other than current)
  - User tries to export CSV
- Paywall shows current pricing and feature comparison (free vs premium)
- Until RevenueCat is connected, purchase buttons show "Coming soon — free during beta"

### 2.3 RevenueCat Integration

**Prerequisite:** Apple Developer account + Google Play Developer account.

**Solution:**
- Re-enable `purchases_flutter` in pubspec.yaml
- Configure RevenueCat with iOS + Android API keys
- `SubscriptionRepository.isPremium()` reads from RevenueCat customer info
- Paywall purchase buttons trigger RevenueCat purchase flow
- Restore Purchases calls RevenueCat restore
- 14-day free trial for new couples (trial starts when partner joins)

### 2.4 Trial Banner and Expiry Nudge

**Problem:** Users on trial have no visibility into when it ends.

**Solution:**
- Show a banner on dashboard: "Trial ends in X days — Upgrade to keep Premium"
- Banner appears when trial has 7 or fewer days remaining
- Push notification 3 days before trial expires (Cloud Function)
- After trial expires, user is downgraded to free tier automatically

---

## Faza 3: Polish for Store

### 3.1 Onboarding Screens

- 3 slides shown on first app launch:
  1. "Track expenses together" — couple illustration
  2. "Set budgets, stay on track" — budget progress illustration
  3. "Privacy you control" — lock illustration
- PageView with dots indicator, "Skip" and "Get Started" buttons
- Show only once (flag in SharedPreferences)

### 3.2 Partner B Tutorial

- When Partner B accepts an invite and lands on dashboard for the first time, show a brief overlay tutorial (3 steps):
  1. "Your partner invited you!" — welcome message
  2. "Tap + to add expenses" — points to FAB
  3. "Control what's shared" — points to Settings > Privacy
- Show only once per user (flag in Firestore user document)

### 3.3 Notifications

- Save FCM token to user's Firestore document on every login and token refresh
- Foreground notifications via `flutter_local_notifications`
- Budget alert Cloud Function: trigger at 80% and 100% of budget limit
- Partner activity notification (existing Cloud Function, just needs working FCM token)

### 3.4 Tests

- Unit tests: currency helper, expense model, budget calculations
- Widget tests: login screen, add expense screen, dashboard
- Integration tests: auth flow (register → skip → dashboard → add expense)

### 3.5 App Store / Play Store Preparation

- Final app icon (already prepared in earlier commit)
- Screenshots for all required device sizes
- App description, keywords, categories
- Privacy policy and support URLs (already exist in docs/)
- TestFlight build for iOS beta testing
- Internal testing track for Android beta
- Requires: Apple Developer ($99/year) + Google Play Developer ($25 one-time)

---

## Post-Launch (V1.1)

Not in scope for V1.0, planned as updates after launch:

- Google Sign-In / Apple Sign-In
- Dark mode
- CSV export (premium feature)
- Recurring expenses
- Savings goals
- Weekly digest email/notification
- Plaid bank sync (V2)
- Receipt scanning (V2)
- Multi-currency per couple (V2)

---

## Architecture Notes

### Existing Patterns to Follow

- Feature-first structure: `features/{name}/data|domain|presentation`
- Riverpod 2.x with code generation (`@riverpod` annotations)
- Freezed for immutable models
- GoRouter for navigation with auth redirect
- Firebase Firestore for persistence
- Repository pattern with abstract interfaces

### New Files Expected

- `lib/src/utils/currency_helper.dart` — currency code to symbol mapping
- `lib/src/features/reports/presentation/reports_screen.dart` — reports tab
- `lib/src/features/onboarding/presentation/onboarding_screen.dart` — welcome slides
- `lib/src/features/budgets/presentation/add_budget_screen.dart` — already exists

### Data Changes

- `Expense` documents: add `userName` field (denormalized)
- No schema migrations needed — new fields are additive
