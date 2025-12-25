import 'package:cloud_firestore/cloud_firestore.dart';

/// Activity action types
enum ActivityAction {
  /// Item created
  created,

  /// Item updated (generic update)
  updated,

  /// Item deleted
  deleted,

  /// Item assigned to someone
  assigned,

  /// Item unassigned
  unassigned,

  /// State changed (todo -> doing -> done)
  stateChanged,

  /// Type changed (activeTask -> bug etc)
  typeChanged,

  /// Priority changed
  priorityChanged,

  /// Title or description edited
  contentEdited;

  String get value => name;

  String get displayName {
    switch (this) {
      case ActivityAction.created:
        return 'Oluşturuldu';
      case ActivityAction.updated:
        return 'Güncellendi';
      case ActivityAction.deleted:
        return 'Silindi';
      case ActivityAction.assigned:
        return 'Atandı';
      case ActivityAction.unassigned:
        return 'Atama kaldırıldı';
      case ActivityAction.stateChanged:
        return 'Durum değişti';
      case ActivityAction.typeChanged:
        return 'Tür değişti';
      case ActivityAction.priorityChanged:
        return 'Öncelik değişti';
      case ActivityAction.contentEdited:
        return 'İçerik düzenlendi';
    }
  }

  String get emoji {
    switch (this) {
      case ActivityAction.created:
        return '✨';
      case ActivityAction.updated:
        return '📝';
      case ActivityAction.deleted:
        return '🗑️';
      case ActivityAction.assigned:
        return '👤';
      case ActivityAction.unassigned:
        return '👤';
      case ActivityAction.stateChanged:
        return '🔄';
      case ActivityAction.typeChanged:
        return '🏷️';
      case ActivityAction.priorityChanged:
        return '🎯';
      case ActivityAction.contentEdited:
        return '✏️';
    }
  }

  static ActivityAction fromString(String value) {
    return ActivityAction.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ActivityAction.updated,
    );
  }
}

/// Activity model - stored at /workspaces/{workspaceId}/activities/{activityId}
class ItemActivity {
  final String id;
  final String workspaceId;
  final String itemId;
  final String? itemTitle;
  final ActivityAction action;
  final String actorUserId;
  final String actorName;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;

  const ItemActivity({
    required this.id,
    required this.workspaceId,
    required this.itemId,
    this.itemTitle,
    required this.action,
    required this.actorUserId,
    required this.actorName,
    this.payload,
    required this.createdAt,
  });

  factory ItemActivity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String workspaceId,
  ) {
    final data = doc.data()!;
    return ItemActivity(
      id: doc.id,
      workspaceId: workspaceId,
      itemId: data['itemId'] as String,
      itemTitle: data['itemTitle'] as String?,
      action: ActivityAction.fromString(data['action'] as String),
      actorUserId: data['actorUserId'] as String,
      actorName: data['actorName'] as String? ?? 'Anonim',
      payload: data['payload'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'itemTitle': itemTitle,
      'action': action.value,
      'actorUserId': actorUserId,
      'actorName': actorName,
      'payload': payload,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Get a human-readable description of the activity
  String getDescription({String? targetName}) {
    final actor = actorName;
    final item = itemTitle ?? 'bir görev';

    switch (action) {
      case ActivityAction.created:
        return '$actor "$item" oluşturdu';
      case ActivityAction.updated:
        return '$actor "$item" güncelledi';
      case ActivityAction.deleted:
        return '$actor "$item" sildi';
      case ActivityAction.assigned:
        final assignee = targetName ?? payload?['assigneeName'] ?? 'birine';
        return '$actor "$item" görevini $assignee atadı';
      case ActivityAction.unassigned:
        return '$actor "$item" atamasını kaldırdı';
      case ActivityAction.stateChanged:
        final from = payload?['fromState'] ?? '';
        final to = payload?['toState'] ?? '';
        return '$actor "$item" durumunu değiştirdi: $from → $to';
      case ActivityAction.typeChanged:
        final from = payload?['fromType'] ?? '';
        final to = payload?['toType'] ?? '';
        return '$actor "$item" türünü değiştirdi: $from → $to';
      case ActivityAction.priorityChanged:
        final from = payload?['fromPriority'] ?? '';
        final to = payload?['toPriority'] ?? '';
        return '$actor "$item" önceliğini değiştirdi: $from → $to';
      case ActivityAction.contentEdited:
        return '$actor "$item" içeriğini düzenledi';
    }
  }

  /// Get short description for compact views
  String get shortDescription {
    final item = itemTitle ?? 'Görev';
    return '${action.emoji} $item ${action.displayName.toLowerCase()}';
  }

  @override
  String toString() =>
      'ItemActivity(id: $id, action: $action, itemId: $itemId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemActivity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, workspaceId);
}
