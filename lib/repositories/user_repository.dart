import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'firestore_paths.dart';

/// Repository for user-related Firestore operations
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get user document reference
  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection(FirestorePaths.users).doc(uid);
  }

  /// Create a new user
  Future<AppUser> createUser({
    required String uid,
    required String displayName,
  }) async {
    final user = AppUser(
      id: uid,
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    await _userDoc(uid).set(user.toFirestore());
    return user;
  }

  /// Get user by ID
  Future<AppUser?> getUser(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Update user display name
  Future<void> updateDisplayName(String uid, String displayName) async {
    await _userDoc(uid).update({'displayName': displayName});
  }

  /// Check if user exists
  Future<bool> userExists(String uid) async {
    final doc = await _userDoc(uid).get();
    return doc.exists;
  }

  /// Stream user data
  Stream<AppUser?> watchUser(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }
}
