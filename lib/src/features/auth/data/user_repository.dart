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
