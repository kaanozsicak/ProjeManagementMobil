import 'package:cloud_firestore/cloud_firestore.dart';

/// User presence status
enum PresenceStatus {
  /// Available, not actively working
  idle,

  /// Actively working on something
  active,

  /// Busy, do not disturb
  busy,

  /// Away from keyboard
  away;

  String get value => name;

  String get displayName {
    switch (this) {
      case PresenceStatus.idle:
        return 'Boşta';
      case PresenceStatus.active:
        return 'Aktif';
      case PresenceStatus.busy:
        return 'Meşgul';
      case PresenceStatus.away:
        return 'Uzakta';
    }
  }

  String get emoji {
    switch (this) {
      case PresenceStatus.idle:
        return '🟢';
      case PresenceStatus.active:
        return '🔵';
      case PresenceStatus.busy:
        return '🔴';
      case PresenceStatus.away:
        return '🟡';
    }
  }

  /// Color value as int (can be used with Color(value) in Flutter)
  int get colorValue {
    switch (this) {
      case PresenceStatus.idle:
        return 0xFF4CAF50; // Green
      case PresenceStatus.active:
        return 0xFF2196F3; // Blue
      case PresenceStatus.busy:
        return 0xFFF44336; // Red
      case PresenceStatus.away:
        return 0xFFFFC107; // Amber
    }
  }

  static PresenceStatus fromString(String value) {
    return PresenceStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PresenceStatus.idle,
    );
  }
}

/// Presence model - stored at /workspaces/{workspaceId}/presence/{userId}
class Presence {
  final String workspaceId;
  final String userId;
  final PresenceStatus status;
  final String? message;
  final DateTime updatedAt;

  const Presence({
    required this.workspaceId,
    required this.userId,
    required this.status,
    this.message,
    required this.updatedAt,
  });

  factory Presence.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String workspaceId,
  ) {
    final data = doc.data()!;
    return Presence(
      workspaceId: workspaceId,
      userId: doc.id,
      status: PresenceStatus.fromString(data['status'] as String),
      message: data['message'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'status': status.value,
      'message': message,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Presence copyWith({
    String? workspaceId,
    String? userId,
    PresenceStatus? status,
    String? message,
    bool clearMessage = false,
    DateTime? updatedAt,
  }) {
    return Presence(
      workspaceId: workspaceId ?? this.workspaceId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user has a custom message
  bool get hasMessage => message != null && message!.isNotEmpty;

  /// Get display text (emoji + status + message)
  String get displayText {
    if (hasMessage) {
      return '${status.emoji} ${status.displayName} - $message';
    }
    return '${status.emoji} ${status.displayName}';
  }

  /// Get short display (just emoji + message or status)
  String get shortDisplay {
    if (hasMessage) {
      return '${status.emoji} $message';
    }
    return '${status.emoji} ${status.displayName}';
  }

  @override
  String toString() =>
      'Presence(userId: $userId, status: $status, message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Presence &&
          runtimeType == other.runtimeType &&
          workspaceId == other.workspaceId &&
          userId == other.userId;

  @override
  int get hashCode => Object.hash(workspaceId, userId);
}
