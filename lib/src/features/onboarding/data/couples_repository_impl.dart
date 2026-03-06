import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/onboarding/domain/couple.dart';
import 'package:moneymate/src/features/onboarding/domain/couple_invite.dart';
import 'package:moneymate/src/features/onboarding/domain/couples_repository.dart';

part 'couples_repository_impl.g.dart';

@Riverpod(keepAlive: true)
CouplesRepositoryImpl couplesRepository(CouplesRepositoryRef ref) {
  return CouplesRepositoryImpl(ref.watch(firestoreProvider));
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

      transaction.update(
        _firestore.collection('users').doc(creatorUserId),
        {'coupleId': coupleRef.id},
      );
      transaction.update(
        _firestore.collection('users').doc(userId),
        {'coupleId': coupleRef.id},
      );

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
