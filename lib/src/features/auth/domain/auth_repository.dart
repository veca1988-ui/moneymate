import 'package:moneymate/src/features/auth/domain/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String name,
    String currency,
  );
  Future<void> signOut();
  Future<void> deleteAccount();
  String? get currentUserId;
}
