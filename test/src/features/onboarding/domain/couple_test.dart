import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/src/features/onboarding/domain/couple.dart';

void main() {
  group('Couple', () {
    final now = DateTime.now();

    test('creates couple with required fields', () {
      final couple = Couple(
        id: 'c1',
        user1Id: 'user1',
        user2Id: 'user2',
        createdAt: now,
        subscriptionStatus: 'trial',
        trialStartDate: now,
        trialEndDate: now.add(const Duration(days: 14)),
      );

      expect(couple.id, 'c1');
      expect(couple.user1Id, 'user1');
      expect(couple.user2Id, 'user2');
      expect(couple.subscriberUserId, isNull);
      expect(couple.expiresAt, isNull);
    });

    test('trial status check returns true when subscriptionStatus is trial', () {
      final couple = Couple(
        id: 'c2',
        user1Id: 'user1',
        user2Id: 'user2',
        createdAt: now,
        subscriptionStatus: 'trial',
        trialStartDate: now,
        trialEndDate: now.add(const Duration(days: 14)),
      );

      expect(couple.subscriptionStatus == 'trial', isTrue);
    });

    test('trial status check returns false when subscriptionStatus is active', () {
      final couple = Couple(
        id: 'c3',
        user1Id: 'user1',
        user2Id: 'user2',
        createdAt: now,
        subscriptionStatus: 'active',
        trialStartDate: now,
        trialEndDate: now.add(const Duration(days: 14)),
      );

      expect(couple.subscriptionStatus == 'trial', isFalse);
    });

    test('trial days remaining is calculated from trialEndDate', () {
      final trialEndDate = now.add(const Duration(days: 7));
      final couple = Couple(
        id: 'c4',
        user1Id: 'user1',
        user2Id: 'user2',
        createdAt: now,
        subscriptionStatus: 'trial',
        trialStartDate: now,
        trialEndDate: trialEndDate,
      );

      final daysRemaining = couple.trialEndDate.difference(DateTime.now()).inDays;

      expect(daysRemaining, 6);
    });

    test('trial days remaining is negative when trial has expired', () {
      final trialEndDate = now.subtract(const Duration(days: 3));
      final couple = Couple(
        id: 'c5',
        user1Id: 'user1',
        user2Id: 'user2',
        createdAt: now,
        subscriptionStatus: 'expired',
        trialStartDate: now.subtract(const Duration(days: 17)),
        trialEndDate: trialEndDate,
      );

      final daysRemaining = couple.trialEndDate.difference(DateTime.now()).inDays;

      expect(daysRemaining, isNegative);
    });
  });
}
