import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'firestore_paths.dart';

/// Repository for presence-related Firestore operations
class PresenceRepository {
  final FirebaseFirestore _firestore;

  PresenceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get presence collection reference for a workspace
  CollectionReference<Map<String, dynamic>> _presenceCollection(
    String workspaceId,
  ) {
    return _firestore.collection(FirestorePaths.workspacePresence(workspaceId));
  }

  /// Get presence document reference
  DocumentReference<Map<String, dynamic>> _presenceDoc(
    String workspaceId,
    String userId,
  ) {
    return _firestore.doc(FirestorePaths.userPresence(workspaceId, userId));
  }

  /// Get user's presence in a workspace
  Future<Presence?> getPresence(String workspaceId, String userId) async {
    final doc = await _presenceDoc(workspaceId, userId).get();
    if (!doc.exists) return null;
    return Presence.fromFirestore(doc, workspaceId);
  }

  /// Update user's presence (create if not exists)
  Future<Presence> updatePresence({
    required String workspaceId,
    required String userId,
    required PresenceStatus status,
    String? message,
  }) async {
    final presence = Presence(
      workspaceId: workspaceId,
      userId: userId,
      status: status,
      message: message,
      updatedAt: DateTime.now(),
    );

    await _presenceDoc(workspaceId, userId).set(
      presence.toFirestore(),
      SetOptions(merge: true),
    );

    return presence;
  }

  /// Update only the status
  Future<void> updateStatus(
    String workspaceId,
    String userId,
    PresenceStatus status,
  ) async {
    await _presenceDoc(workspaceId, userId).set({
      'status': status.value,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Update only the message
  Future<void> updateMessage(
    String workspaceId,
    String userId,
    String? message,
  ) async {
    await _presenceDoc(workspaceId, userId).set({
      'message': message,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Clear user's message
  Future<void> clearMessage(String workspaceId, String userId) async {
    await updateMessage(workspaceId, userId, null);
  }

  /// Get all presence data for a workspace
  Future<List<Presence>> getWorkspacePresence(String workspaceId) async {
    final snapshot = await _presenceCollection(workspaceId).get();
    return snapshot.docs
        .map((doc) => Presence.fromFirestore(doc, workspaceId))
        .toList();
  }

  /// Stream all presence data for a workspace (real-time)
  Stream<List<Presence>> watchWorkspacePresence(String workspaceId) {
    return _presenceCollection(workspaceId).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Presence.fromFirestore(doc, workspaceId))
            .toList());
  }

  /// Stream single user's presence
  Stream<Presence?> watchUserPresence(String workspaceId, String userId) {
    return _presenceDoc(workspaceId, userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Presence.fromFirestore(doc, workspaceId);
    });
  }

  /// Get presence map (userId -> Presence) for a workspace
  Future<Map<String, Presence>> getPresenceMap(String workspaceId) async {
    final presenceList = await getWorkspacePresence(workspaceId);
    return {for (final p in presenceList) p.userId: p};
  }

  /// Stream presence map
  Stream<Map<String, Presence>> watchPresenceMap(String workspaceId) {
    return watchWorkspacePresence(workspaceId).map(
      (list) => {for (final p in list) p.userId: p},
    );
  }

  /// Set user as active when they start working on an item
  Future<void> setActiveWithItem(
    String workspaceId,
    String userId,
    String itemTitle,
  ) async {
    await updatePresence(
      workspaceId: workspaceId,
      userId: userId,
      status: PresenceStatus.active,
      message: itemTitle,
    );
  }

  /// Set user as idle (default state)
  Future<void> setIdle(String workspaceId, String userId) async {
    await updatePresence(
      workspaceId: workspaceId,
      userId: userId,
      status: PresenceStatus.idle,
      message: null,
    );
  }
}
