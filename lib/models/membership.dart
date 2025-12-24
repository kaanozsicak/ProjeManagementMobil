import 'package:cloud_firestore/cloud_firestore.dart';

/// Member role in a workspace
enum MemberRole {
  owner,
  member;

  String get value => name;

  static MemberRole fromString(String value) {
    return MemberRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MemberRole.member,
    );
  }
}

/// Membership model - stored at /workspaces/{workspaceId}/members/{uid}
class Membership {
  final String workspaceId;
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;

  const Membership({
    required this.workspaceId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory Membership.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String workspaceId,
  ) {
    final data = doc.data()!;
    return Membership(
      workspaceId: workspaceId,
      userId: doc.id,
      role: MemberRole.fromString(data['role'] as String),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'role': role.value,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  bool get isOwner => role == MemberRole.owner;
  bool get isMember => role == MemberRole.member;

  @override
  String toString() =>
      'Membership(workspaceId: $workspaceId, userId: $userId, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Membership &&
          runtimeType == other.runtimeType &&
          workspaceId == other.workspaceId &&
          userId == other.userId;

  @override
  int get hashCode => Object.hash(workspaceId, userId);
}
