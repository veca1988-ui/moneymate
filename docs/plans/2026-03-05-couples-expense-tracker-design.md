# Couples Expense Tracker — Design Specification

**Date**: 2026-03-05
**Status**: Approved
**Version**: 1.0

---

## 1. Product Overview

### What
A mobile app (iOS + Android) for couples to track shared expenses and budgets together, with privacy controls that respect financial independence.

### Why
Honeydue (the only purpose-built couples finance app) appears abandoned — unreliable sync, no updates, unresponsive support. The market has a clear gap for a reliable, well-designed couples finance app.

### Target User
Couples (2 people) at any relationship stage — dating, engaged, married — who want to manage money together while maintaining some financial privacy.

### Working Name
TBD — "MoneyMate" is a placeholder. Final name requires:
- USPTO trademark search
- App Store availability check
- Domain availability (.com, .app)
- Social media handle availability
- Candidates: Paired, Couplet, OurBudget, DuoSpend

### Positioning Statement
"The only budget app designed for your relationship — manage money together without losing your financial independence."

---

## 2. Monetization Model

### Freemium (soft paywall)

Chosen over hard paywall to solve the **two-sided activation problem**: both partners must experience value before either will pay.

#### Free Tier (forever)
- Manual expense entry (up to 30 entries/month)
- 5 default categories
- Basic monthly overview (totals only, no charts)
- Partner invite and basic shared view
- Push notifications for partner activity

#### Premium Tier
- **Monthly**: $3.99/month
- **Annual**: $34.99/year (27% discount)
- No lifetime option at launch

Premium unlocks:
- Unlimited expense entries
- Custom categories with per-category budgets and progress bars
- Full charts and analytics (pie chart, spending breakdown)
- Privacy controls per category
- Recurring expenses (v1.1)
- Savings goals with progress bars (v1.1)
- CSV data export (v2)

#### Trial
- **14-day free trial** of Premium (starts when couple is formed, not at registration)
- Small banner during trial: "Trial ends in X days"
- Push notification reminder 3 days before expiry
- After trial: graceful downgrade to Free tier (not a lock screen)

#### Subscription Ownership
- **Per-couple**: one partner pays, both get Premium access
- Stored on the couple document: `subscriptionStatus`, `subscriberUserId`, `expiresAt`
- Managed via RevenueCat webhooks → Cloud Functions

---

## 3. V1 Feature Set

### V1.0 — Core Launch (8-10 weeks)

**Must-have:**

1. **Fast manual expense entry** (2-3 taps, inspired by Monefy)
   - Amount → Category → Save
   - Optional: note, date override

2. **Categories with per-category budgets**
   - Default categories: Groceries, Dining, Transport, Bills, Entertainment, Shopping, Health, Other
   - Premium: custom categories, budget limits with progress bars
   - Budget alerts at 80% and 100%

3. **Monthly overview**
   - Free: total spent, total by category (numbers only)
   - Premium: pie chart spending breakdown

4. **Partner invite system**
   - Invite via shareable link (deep link)
   - Time-limited invite code (48h expiry)
   - Cloud Function validates and creates couple document

5. **Partner B onboarding flow** (CRITICAL — most important UX)
   - Partner B receives link → downloads app → creates account → auto-joins couple
   - Must complete in under 60 seconds
   - If Partner B hasn't joined in 24h: reminder notification to Partner A
   - "Sarah hasn't joined yet" nudge

6. **Shared budgets with privacy controls** (Premium)
   - Per-category privacy settings:
     - **Share all**: partner sees every transaction and amount
     - **Share total only**: partner sees category total but not individual transactions
     - **Private**: partner sees nothing in this category

7. **Push notifications**
   - Partner adds expense to shared category
   - Budget approaching limit (80%)
   - Budget exceeded (100%)
   - Notification throttling: batch partner activity notifications, max 1 per 15 minutes

8. **Account deletion** (legal requirement for both stores)
   - Cloud Function: deletes user data, Firebase Auth account, handles partner's view, cancels RevenueCat subscription

9. **Currency selection** at registration (single currency per couple, multi-currency in v2)

10. **Analytics for developer** (internal, not user-facing)
    - Activation rates (D1, D7, D30 for both partners)
    - Trial-to-paid conversion
    - Partner B activation rate within 48h
    - Feature usage tracking via Firebase Analytics

### V1.1 — Fast Follow (weeks 11-14)

- Recurring expenses (auto-added monthly/weekly)
- Savings goals with progress bars and projected completion date
- Dark mode
- Weekly digest notification ("This week you and [partner] spent $X")

### V2 — Growth Features (months 4-6)

- Bank sync via Plaid (automatic transaction import)
- Receipt scanning (server-side OCR via Veryfi or GPT-4 Vision, NOT on-device ML Kit)
- Multi-currency support
- CSV/PDF data export
- Bar charts and trend analysis
- Monthly "money date" reminder feature
- Referral program ("Invite a couple, both couples get 1 month free")

---

## 4. Technical Architecture

### Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| Frontend | Flutter (Dart) | Single codebase for iOS + Android, excellent UI |
| Backend | Firebase (Firestore, Auth, Cloud Functions, Cloud Messaging) | Fast development, real-time sync, generous free tier |
| State Management | Riverpod 2.x with code generation | Modern, testable, handles caching and disposal |
| Subscriptions | RevenueCat | Handles Apple/Google payments, receipt validation, edge cases |
| Analytics | Firebase Analytics + Crashlytics | Free, integrated |
| Deep Linking | Branch.io or custom URL schemes | Firebase Dynamic Links deprecated (Aug 2025) |

### Project Structure (Modular with Repository Pattern)

```
lib/
├── core/
│   ├── theme/              # App theme, colors, typography
│   ├── constants/          # App-wide constants
│   ├── utils/              # Utility functions
│   └── widgets/            # Shared widgets
├── domain/
│   ├── models/             # Domain models (Expense, Budget, User, Couple)
│   └── repositories/       # Abstract repository interfaces
├── data/
│   ├── repositories/       # Repository implementations (Firebase)
│   ├── datasources/        # Firebase services, local cache
│   └── dtos/               # Firebase-specific data transfer objects
├── features/
│   ├── auth/
│   │   ├── presentation/   # Login, register screens
│   │   ├── providers/      # Riverpod providers
│   │   └── application/    # Auth use cases
│   ├── onboarding/
│   │   ├── presentation/   # Onboarding flow, partner invite
│   │   └── providers/
│   ├── expenses/
│   │   ├── presentation/   # Add expense, expense list
│   │   ├── providers/
│   │   └── application/    # Expense business logic
│   ├── budgets/
│   │   ├── presentation/   # Budget list, progress bars
│   │   ├── providers/
│   │   └── application/
│   ├── dashboard/
│   │   ├── presentation/   # Monthly overview, charts
│   │   └── providers/
│   ├── settings/
│   │   ├── presentation/   # Privacy, notifications, account
│   │   └── providers/
│   └── subscription/
│       ├── presentation/   # Paywall, plan selection
│       └── providers/
├── services/
│   ├── notification_service.dart
│   ├── deep_link_service.dart
│   └── analytics_service.dart
└── main.dart
```

### Why Repository Pattern
- **Testability**: Mock repositories in tests without mocking Firebase
- **Migration safety**: If we move off Firestore at scale, we change one layer
- **Offline support**: Repository can transparently switch between local cache and remote

---

## 5. Database Design (Firestore)

### Schema

```
users/{userId}
  - email: string
  - name: string
  - coupleId: string (nullable — null until couple is formed)
  - currency: string (e.g., "USD", "EUR", "RSD")
  - createdAt: timestamp
  - fcmToken: string (for push notifications)

couples/{coupleId}
  - user1Id: string
  - user2Id: string
  - createdAt: timestamp
  - subscriptionStatus: "trial" | "active" | "expired" | "free"
  - subscriberUserId: string (nullable — who pays)
  - trialStartDate: timestamp
  - trialEndDate: timestamp
  - expiresAt: timestamp (nullable)

  privacySettings/{userId}  (subcollection — one doc per user)
    - {category}: "all" | "total" | "private"
    (e.g., "groceries": "all", "personal": "private")

  expenses/{expenseId}  (subcollection)
    - amount: number (positive)
    - category: string
    - note: string (optional)
    - date: timestamp
    - userId: string (who created it)
    - createdAt: timestamp
    - visibility: "shared" | "private"
    (private expenses are only readable by the owner via security rules)

  budgets/{budgetId}  (subcollection)
    - category: string
    - limit: number
    - month: string (e.g., "2026-03")
    (NOTE: "spent" is NOT stored — calculated dynamically via aggregation query)

coupleInvites/{inviteCode}
  - creatorUserId: string
  - coupleId: string
  - createdAt: timestamp
  - expiresAt: timestamp (createdAt + 48h)
  - used: boolean
```

### Key Design Decisions

1. **`spent` is NOT stored on budgets** — calculated dynamically via Firestore `sum()` aggregation to prevent desync bugs. Cached client-side with Riverpod.

2. **Privacy enforced server-side** — private expenses have `visibility: "private"` and security rules restrict reads to the owner. Cloud Functions filter "total only" categories.

3. **`coupleId` on user document** — enables direct document read instead of query.

4. **Separate `coupleInvites` collection** — time-limited invite codes validated by Cloud Function, not client-side.

5. **No `deletedAt` field** — expenses are hard-deleted in v1. Audit trail considered for v2.

### Composite Indexes Needed
- `expenses`: `category + date` (for monthly category queries)
- `expenses`: `userId + date` (for per-user queries)
- `expenses`: `visibility + date` (for privacy-filtered queries)

### Firestore Security Rules (Simplified)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users: read/write own document only
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Couples: only members can read/write
    match /couples/{coupleId} {
      allow read: if isCoupleMember(coupleId);

      // Expenses: members can read shared, only owner can read private
      match /expenses/{expenseId} {
        allow read: if isCoupleMember(coupleId) &&
          (resource.data.visibility == "shared" ||
           resource.data.userId == request.auth.uid);
        allow create: if isCoupleMember(coupleId) &&
          request.resource.data.userId == request.auth.uid &&
          request.resource.data.amount > 0;
        allow update, delete: if isCoupleMember(coupleId) &&
          resource.data.userId == request.auth.uid;
      }

      // Budgets: both members can read/write
      match /budgets/{budgetId} {
        allow read, write: if isCoupleMember(coupleId);
      }

      // Privacy settings: only the owner can write their settings
      match /privacySettings/{userId} {
        allow read: if isCoupleMember(coupleId);
        allow write: if request.auth.uid == userId;
      }
    }

    // Invite codes: anyone authenticated can read (to validate), only creator writes
    match /coupleInvites/{inviteCode} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }

    function isCoupleMember(coupleId) {
      let couple = get(/databases/$(database)/documents/couples/$(coupleId));
      return request.auth != null &&
        (couple.data.user1Id == request.auth.uid ||
         couple.data.user2Id == request.auth.uid);
    }
  }
}
```

### Data Validation (in Security Rules)
- `amount` must be a positive number
- `category` must be from a known list
- `date` must not be more than 1 year in the future
- `userId` must match authenticated user
- Required fields must be present

---

## 6. Key User Flows

### Flow 1: Registration + Couple Formation (Partner A)
1. Open app → Welcome screen
2. Sign up (email/password or Google/Apple sign-in)
3. Choose currency
4. "Invite your partner" screen → generates shareable invite link
5. Share link via Messages, WhatsApp, etc.
6. Land on empty dashboard with "Waiting for [partner]..." state
7. Trial starts when Partner B joins (NOT at registration)

### Flow 2: Partner B Onboarding (CRITICAL — under 60 seconds)
1. Partner B taps invite link → App Store/Play Store (if not installed) or direct to app
2. Sign up (email/password or Google/Apple sign-in)
3. Choose currency (pre-filled from Partner A's choice)
4. Auto-joined to couple → both see shared dashboard immediately
5. Brief tutorial: "Here's how to add an expense" (3 screens max)

### Flow 3: Adding an Expense
1. Tap "+" button (floating action button, always visible)
2. Enter amount (number pad, large and clear)
3. Select category (grid of icons)
4. Optional: add note, change date
5. Tap "Save" → expense appears in list, partner gets notification (if shared category)
Total: 2-3 taps for basic entry, 4-5 taps with note/date.

### Flow 4: Breakup / Unlinking
1. Settings → "Unlink from partner"
2. Confirmation: "This will remove the connection. Your personal data stays."
3. Cloud Function: removes coupleId from both users, archives couple data
4. Both users can continue using the app individually (free tier)
5. Historical shared data: each user retains a read-only copy of shared expenses

---

## 7. Notification Strategy

### Types
| Trigger | Recipient | Throttling |
|---------|-----------|-----------|
| Partner adds shared expense | Other partner | Max 1 per 15 min (batch) |
| Budget at 80% | Both partners | Once per budget per month |
| Budget exceeded (100%) | Both partners | Once per budget per month |
| Trial ending in 3 days | Both partners | Once |
| Partner B hasn't joined (24h) | Partner A | Once |
| Weekly digest | Both partners | Every Sunday |

### Notification Throttling
Partner activity notifications are batched: if Partner A adds 10 expenses in 5 minutes, Partner B gets ONE notification: "Sarah added 10 expenses totaling $127."

---

## 8. Launch Strategy

### Phase 1: Beta (Weeks 1-4 after development)
- TestFlight (iOS) + Firebase App Distribution (Android)
- 50-100 couples from Reddit, friends, couples communities
- Focus: Does partner invite work? Do both partners use it? Is entry fast enough?
- Key metric: Partner B D7 retention > 40%

### Phase 2: Soft Launch (Weeks 5-8)
- Launch in **Canada** (English-speaking, similar financial culture, smaller market for mistakes)
- Target: 500+ downloads, 15% trial start rate, 5% trial-to-paid conversion
- Fix issues found in real-world usage

### Phase 3: US Launch (Week 9+)
- Full US App Store + Google Play launch
- Coordinate with ProductHunt launch
- Have 20-30 five-star reviews from beta users
- Best timing: January (New Year resolutions) or September (back to routine)

### User Acquisition Channels
1. **Reddit** (r/personalfinance, r/couples, r/ynab) — $0, 5-10h/week
2. **TikTok/Instagram Reels** — couples finance content, 3-5 videos/week
3. **ProductHunt** launch — expect 200-500 sign-ups
4. **Apple Search Ads** — $500/month, target CAC < $3.00
5. **Micro-influencers** — $200-500 per post, couples/finance niche
6. **Referral program** (v1.1) — "Invite a couple, both get 1 month free"

### ASO Keywords
Primary: "couple budget app", "shared expense tracker", "couples finance", "budget app for two"
Secondary: "couple expense tracker", "shared budget", "honeydue alternative"

---

## 9. Revenue Projections (Realistic)

### Assumptions
- Freemium with 14-day Premium trial
- 5% free-to-trial, 40% trial-to-paid (2% net conversion)
- $3.99/month average (blend of monthly/annual)
- 20% monthly churn on paid (normal for new apps)
- Apple/Google take 15% (Small Business Program)

### Year 1
| Quarter | Downloads | Paid Users | MRR | Net Revenue |
|---------|-----------|-----------|-----|-------------|
| Q1 | 1,000 | 20 | $80 | $68 |
| Q2 | 5,000 | 80 | $320 | $272 |
| Q3 | 15,000 | 200 | $800 | $680 |
| Q4 | 35,000 | 450 | $1,800 | $1,530 |

**Year 1 total**: ~$8,000-12,000 net revenue
**Year 1 Firebase costs**: ~$300-600

### Year 2 (with product-market fit)
| Quarter | Downloads | Paid Users | MRR | Net Revenue |
|---------|-----------|-----------|-----|-------------|
| Q1 | 60,000 | 800 | $3,200 | $2,720 |
| Q2 | 100,000 | 1,500 | $6,000 | $5,100 |
| Q3 | 160,000 | 2,500 | $10,000 | $8,500 |
| Q4 | 250,000 | 4,000 | $16,000 | $13,600 |

**Year 2 total**: ~$80,000-120,000 net revenue

### Fixed Costs
| Item | Cost |
|------|------|
| Apple Developer | $99/year |
| Google Play Developer | $25 one-time |
| RevenueCat | Free up to $2.5K MTR |
| Firebase (Year 1) | ~$300-600/year |

---

## 10. Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Partner B doesn't activate | CRITICAL | Best-in-class onboarding, 24h/48h nudges |
| Breakups kill 2 users at once | HIGH | Accept as structural; optimize single-user experience post-breakup |
| Honeydue gets revived/acquired | HIGH | Move fast, ship quality. First-mover advantage in the gap. |
| Low willingness to pay | HIGH | Generous free tier ensures retention; optimize upgrade triggers |
| Firebase vendor lock-in | MEDIUM | Repository pattern enables migration to Supabase/custom backend |
| App Store rejection | MEDIUM | Follow guidelines strictly, clear pricing transparency |
| Firebase costs spike unexpectedly | LOW | Monitor usage, set billing alerts, migration plan ready |

---

## 11. Success Metrics

### North Star Metric
**Couple Weekly Active Rate**: % of couples where BOTH partners used the app in the last 7 days.

### Key Metrics
| Metric | Target |
|--------|--------|
| Partner B activation within 48h | > 60% |
| D7 retention (both partners) | > 40% |
| D30 retention (both partners) | > 25% |
| Trial start rate | > 15% |
| Trial-to-paid conversion | > 5% |
| Monthly churn (paid) | < 15% |
| App Store rating | > 4.5 |

---

## 12. Competitive Advantages Summary

| Us | Them |
|----|------|
| Privacy controls per category | Most apps: all-or-nothing sharing |
| Actively maintained and reliable | Honeydue: appears abandoned |
| Freemium with fair free tier | Splitwise: punitive paywall |
| Fast expense entry (2-3 taps) | YNAB: complex, steep learning curve |
| Beautiful modern UI | Goodbudget: dated design |
| Built specifically for couples | 80% of apps: single user only |
| $3.99/month ($34.99/year) | YNAB: $109/year, PocketGuard: $74.99/year |

---

## Appendix A: V1.0 Screen List

1. Welcome / Landing
2. Sign Up (email + social)
3. Login
4. Currency Selection
5. Invite Partner (generate link)
6. Waiting for Partner
7. Partner B: Accept Invite
8. Quick Tutorial (3 screens)
9. Dashboard (monthly overview)
10. Add Expense
11. Expense List (with filters)
12. Budget List (with progress bars)
13. Budget Detail (category breakdown)
14. Settings
15. Privacy Controls
16. Notification Settings
17. Subscription / Paywall
18. Account Management (delete account, unlink partner)

---

## Appendix B: Development Phases

### Phase 1: Foundation (Weeks 1-2)
- Flutter project setup with modular structure
- Firebase project setup (Auth, Firestore, Cloud Functions)
- Repository pattern implementation
- Domain models and DTOs
- Riverpod providers setup
- Theme and design system

### Phase 2: Auth + Couple Formation (Weeks 3-4)
- Email/password registration and login
- Google Sign-In and Apple Sign-In
- Partner invite flow (deep linking)
- Partner B onboarding
- Couple document creation via Cloud Function
- Firestore security rules

### Phase 3: Core Expense Tracking (Weeks 5-6)
- Fast expense entry screen
- Expense list with monthly view
- Category selection
- Privacy-aware expense visibility
- Push notifications for partner activity (with throttling)

### Phase 4: Budgets + Dashboard (Weeks 7-8)
- Per-category budget creation
- Budget progress bars (dynamic calculation)
- Budget alerts (80%, 100%)
- Monthly dashboard with totals
- Pie chart (Premium)

### Phase 5: Subscription + Polish (Weeks 9-10)
- RevenueCat integration
- Paywall screen
- Trial management (start on couple formation)
- Free/Premium feature gating
- Account deletion flow
- App Store preparation (screenshots, description, metadata)
- Beta testing (TestFlight + Firebase App Distribution)
