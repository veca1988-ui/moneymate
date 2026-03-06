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
