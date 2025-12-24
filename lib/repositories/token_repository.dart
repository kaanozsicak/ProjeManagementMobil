import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'firestore_paths.dart';

/// Repository for FCM token management
class TokenRepository {
  final FirebaseFirestore _firestore;

  TokenRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get user's tokens collection reference
  CollectionReference<Map<String, dynamic>> _tokensCollection(String userId) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(userId)
        .collection('tokens');
  }

  /// Save FCM token for a user
  Future<void> saveToken({
    required String userId,
    required String token,
    String? platform,
  }) async {
    final tokenDoc = _tokensCollection(userId).doc(token);
    
    await tokenDoc.set({
      'token': token,
      'platform': platform ?? _getPlatform(),
      'createdAt': FieldValue.serverTimestamp(),
      'lastUsedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update token's last used timestamp
  Future<void> updateTokenLastUsed(String userId, String token) async {
    final tokenDoc = _tokensCollection(userId).doc(token);
    
    await tokenDoc.update({
      'lastUsedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a specific token
  Future<void> deleteToken(String userId, String token) async {
    await _tokensCollection(userId).doc(token).delete();
  }

  /// Delete all tokens for a user (on logout)
  Future<void> deleteAllTokens(String userId) async {
    final tokens = await _tokensCollection(userId).get();
    final batch = _firestore.batch();
    
    for (final doc in tokens.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  /// Get all tokens for a user
  Future<List<String>> getUserTokens(String userId) async {
    final snapshot = await _tokensCollection(userId).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// Check if token exists
  Future<bool> tokenExists(String userId, String token) async {
    final doc = await _tokensCollection(userId).doc(token).get();
    return doc.exists;
  }

  /// Get platform string
  String _getPlatform() {
    // Platform detection - simplified for now
    return 'unknown';
  }
}
