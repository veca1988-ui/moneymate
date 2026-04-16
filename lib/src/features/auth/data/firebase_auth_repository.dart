import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moneymate/src/features/auth/data/user_repository.dart';
import 'package:moneymate/src/features/auth/domain/app_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_auth_repository.g.dart';

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(FirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@Riverpod(keepAlive: true)
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository(ref.watch(firestoreProvider));
}

@Riverpod(keepAlive: true)
FirebaseAuthRepository firebaseAuthRepository(
  FirebaseAuthRepositoryRef ref,
) {
  return FirebaseAuthRepository(
    FirebaseAuth.instance,
    ref.watch(userRepositoryProvider),
  );
}

@riverpod
Stream<AppUser?> authStateChanges(AuthStateChangesRef ref) {
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
      final user = await _userRepo.getUser(firebaseUser.uid);
      if (user != null) return user;
      // User document may not exist yet (just signed up) — return a minimal user
      // so the router knows the user is authenticated
      return AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? '',
        currency: 'USD',
        createdAt: DateTime.now(),
      );
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

  Future<AppUser?> signInWithGoogle() async {
    final UserCredential userCredential;

    if (kIsWeb) {
      // On web, use signInWithPopup directly
      final provider = GoogleAuthProvider();
      userCredential = await _auth.signInWithPopup(provider);
    } else {
      // On mobile, use GoogleSignIn package
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await _auth.signInWithCredential(credential);
    }

    final firebaseUser = userCredential.user!;

    // Check if user doc exists, create if first time
    var user = await _userRepo.getUser(firebaseUser.uid);
    if (user == null) {
      user = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? '',
        currency: 'USD',
        createdAt: DateTime.now(),
      );
      await _userRepo.createUser(user);
    }
    return user;
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
