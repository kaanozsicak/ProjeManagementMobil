import 'package:cloud_firestore/cloud_firestore.dart';

/// Invite model - stored at /workspaces/{workspaceId}/invites/{token}
class WorkspaceInvite {
  final String token;
  final String workspaceId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int? maxUses;
  final int usesCount;

  const WorkspaceInvite({
    required this.token,
    required this.workspaceId,
    required this.createdBy,
    required this.createdAt,
    required this.expiresAt,
    this.maxUses,
    this.usesCount = 0,
  });

  factory WorkspaceInvite.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String workspaceId,
  ) {
    final data = doc.data()!;
    return WorkspaceInvite(
      token: doc.id,
      workspaceId: workspaceId,
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      maxUses: data['maxUses'] as int?,
      usesCount: (data['usesCount'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'maxUses': maxUses,
      'usesCount': usesCount,
    };
  }

  /// Check if the invite is still valid
  bool get isValid {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return false;
    if (maxUses != null && usesCount >= maxUses!) return false;
    return true;
  }

  /// Check if the invite has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if the invite has reached max uses
  bool get isMaxUsesReached => maxUses != null && usesCount >= maxUses!;

  /// Generate invite link string (not a deep link, just a shareable string)
  String get inviteLink => 'kimne://join?workspace=$workspaceId&token=$token';

  /// Generate a human-readable invite code for easy sharing
  String get inviteCode => '$workspaceId:$token';

  @override
  String toString() =>
      'WorkspaceInvite(token: $token, workspaceId: $workspaceId, valid: $isValid)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceInvite &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(token, workspaceId);
}
