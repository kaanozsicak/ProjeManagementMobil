import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'firestore_paths.dart';

/// Repository for workspace-related Firestore operations
class WorkspaceRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  WorkspaceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = const Uuid();

  /// Get workspace collection reference
  CollectionReference<Map<String, dynamic>> get _workspacesCollection =>
      _firestore.collection(FirestorePaths.workspaces);

  /// Get workspace document reference
  DocumentReference<Map<String, dynamic>> _workspaceDoc(String workspaceId) {
    return _workspacesCollection.doc(workspaceId);
  }

  /// Get members subcollection reference
  CollectionReference<Map<String, dynamic>> _membersCollection(
    String workspaceId,
  ) {
    return _workspaceDoc(workspaceId).collection(FirestorePaths.members);
  }

  /// Get invites subcollection reference
  CollectionReference<Map<String, dynamic>> _invitesCollection(
    String workspaceId,
  ) {
    return _workspaceDoc(workspaceId).collection(FirestorePaths.invites);
  }

  /// Create a new workspace with the creator as owner
  Future<Workspace> createWorkspace({
    required String name,
    required String createdBy,
  }) async {
    final workspaceId = _uuid.v4();
    final now = DateTime.now();

    final workspace = Workspace(
      id: workspaceId,
      name: name,
      createdBy: createdBy,
      createdAt: now,
    );

    final membership = Membership(
      workspaceId: workspaceId,
      userId: createdBy,
      role: MemberRole.owner,
      joinedAt: now,
    );

    // Use batch write for atomic operation
    final batch = _firestore.batch();
    batch.set(_workspaceDoc(workspaceId), workspace.toFirestore());
    batch.set(
      _membersCollection(workspaceId).doc(createdBy),
      membership.toFirestore(),
    );
    await batch.commit();

    return workspace;
  }

  /// Get workspace by ID
  Future<Workspace?> getWorkspace(String workspaceId) async {
    final doc = await _workspaceDoc(workspaceId).get();
    if (!doc.exists) return null;
    return Workspace.fromFirestore(doc);
  }

  /// Get all workspaces where user is a member
  Future<List<Workspace>> getUserWorkspaces(String userId) async {
    // First, get all workspace IDs where user is a member
    // Query members collection where the document ID matches userId
    // We store userId as the document ID in members subcollection
    final membershipQuery = await _firestore
        .collectionGroup(FirestorePaths.members)
        .where('userId', isEqualTo: userId)
        .get();

    if (membershipQuery.docs.isEmpty) return [];

    // Extract workspace IDs from the paths
    final workspaceIds = membershipQuery.docs.map((doc) {
      // Path is: workspaces/{workspaceId}/members/{userId}
      final pathSegments = doc.reference.path.split('/');
      return pathSegments[1]; // workspaceId
    }).toList();

    // Fetch all workspaces
    final workspaces = <Workspace>[];
    for (final workspaceId in workspaceIds) {
      final workspace = await getWorkspace(workspaceId);
      if (workspace != null) {
        workspaces.add(workspace);
      }
    }

    return workspaces;
  }

  /// Stream workspaces where user is a member
  Stream<List<Workspace>> watchUserWorkspaces(String userId) {
    return _firestore
        .collectionGroup(FirestorePaths.members)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return <Workspace>[];

      final workspaceIds = snapshot.docs.map((doc) {
        final pathSegments = doc.reference.path.split('/');
        return pathSegments[1];
      }).toList();

      final workspaces = <Workspace>[];
      for (final workspaceId in workspaceIds) {
        final workspace = await getWorkspace(workspaceId);
        if (workspace != null) {
          workspaces.add(workspace);
        }
      }

      return workspaces;
    });
  }

  /// Check if user is a member of workspace
  Future<bool> isMember(String workspaceId, String userId) async {
    final doc = await _membersCollection(workspaceId).doc(userId).get();
    return doc.exists;
  }

  /// Get membership for a user in a workspace
  Future<Membership?> getMembership(String workspaceId, String userId) async {
    final doc = await _membersCollection(workspaceId).doc(userId).get();
    if (!doc.exists) return null;
    return Membership.fromFirestore(doc, workspaceId);
  }

  /// Get all members of a workspace
  Future<List<Membership>> getWorkspaceMembers(String workspaceId) async {
    final snapshot = await _membersCollection(workspaceId).get();
    return snapshot.docs
        .map((doc) => Membership.fromFirestore(doc, workspaceId))
        .toList();
  }

  /// Add a member to workspace
  Future<Membership> addMember({
    required String workspaceId,
    required String userId,
    MemberRole role = MemberRole.member,
  }) async {
    final membership = Membership(
      workspaceId: workspaceId,
      userId: userId,
      role: role,
      joinedAt: DateTime.now(),
    );

    await _membersCollection(workspaceId).doc(userId).set(
          membership.toFirestore(),
        );

    return membership;
  }

  /// Create an invite for a workspace
  Future<WorkspaceInvite> createInvite({
    required String workspaceId,
    required String createdBy,
    Duration validity = const Duration(days: 7),
    int? maxUses,
  }) async {
    final token = _uuid.v4().substring(0, 8).toUpperCase(); // Short token
    final now = DateTime.now();

    final invite = WorkspaceInvite(
      token: token,
      workspaceId: workspaceId,
      createdBy: createdBy,
      createdAt: now,
      expiresAt: now.add(validity),
      maxUses: maxUses,
    );

    await _invitesCollection(workspaceId).doc(token).set(invite.toFirestore());

    return invite;
  }

  /// Get invite by token
  Future<WorkspaceInvite?> getInvite(
    String workspaceId,
    String token,
  ) async {
    final doc = await _invitesCollection(workspaceId).doc(token).get();
    if (!doc.exists) return null;
    return WorkspaceInvite.fromFirestore(doc, workspaceId);
  }

  /// Validate and use invite (increment usesCount)
  Future<InviteValidationResult> validateAndUseInvite({
    required String workspaceId,
    required String token,
    required String userId,
  }) async {
    // Check if user is already a member
    final existingMembership = await getMembership(workspaceId, userId);
    if (existingMembership != null) {
      return InviteValidationResult.alreadyMember;
    }

    // Get the invite
    final invite = await getInvite(workspaceId, token);
    if (invite == null) {
      return InviteValidationResult.notFound;
    }

    if (invite.isExpired) {
      return InviteValidationResult.expired;
    }

    if (invite.isMaxUsesReached) {
      return InviteValidationResult.maxUsesReached;
    }

    // Use transaction to safely increment usesCount and add member
    await _firestore.runTransaction((transaction) async {
      final inviteRef = _invitesCollection(workspaceId).doc(token);
      final inviteDoc = await transaction.get(inviteRef);

      if (!inviteDoc.exists) {
        throw Exception('Invite not found');
      }

      final currentUses = (inviteDoc.data()?['usesCount'] as int?) ?? 0;
      transaction.update(inviteRef, {'usesCount': currentUses + 1});

      final memberRef = _membersCollection(workspaceId).doc(userId);
      final membership = Membership(
        workspaceId: workspaceId,
        userId: userId,
        role: MemberRole.member,
        joinedAt: DateTime.now(),
      );
      transaction.set(memberRef, membership.toFirestore());
    });

    return InviteValidationResult.success;
  }

  /// Delete a workspace (only owner can do this)
  Future<void> deleteWorkspace(String workspaceId) async {
    // Delete all members
    final membersSnapshot = await _membersCollection(workspaceId).get();
    final batch = _firestore.batch();

    for (final doc in membersSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete all invites
    final invitesSnapshot = await _invitesCollection(workspaceId).get();
    for (final doc in invitesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete workspace
    batch.delete(_workspaceDoc(workspaceId));

    await batch.commit();
  }
}

/// Result of invite validation
enum InviteValidationResult {
  success,
  notFound,
  expired,
  maxUsesReached,
  alreadyMember,
}
