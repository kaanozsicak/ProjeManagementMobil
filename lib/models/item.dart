import 'package:cloud_firestore/cloud_firestore.dart';

/// Item type - determines which board section the item appears in
enum ItemType {
  /// Active task - current work items
  activeTask,

  /// Bug & data issues
  bug,

  /// Logic & refactoring (backend)
  logic,

  /// Ideas that can become tasks
  idea;

  String get value => name;

  String get displayName {
    switch (this) {
      case ItemType.activeTask:
        return 'Aktif Görev';
      case ItemType.bug:
        return 'Hata & Veri';
      case ItemType.logic:
        return 'Geliştirme';
      case ItemType.idea:
        return 'Fikir';
    }
  }

  String get emoji {
    switch (this) {
      case ItemType.activeTask:
        return '🎯';
      case ItemType.bug:
        return '🐛';
      case ItemType.logic:
        return '⚙️';
      case ItemType.idea:
        return '💡';
    }
  }

  static ItemType fromString(String value) {
    return ItemType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ItemType.activeTask,
    );
  }
}

/// Item state - workflow status
enum ItemState {
  /// To do - not started
  todo,

  /// In progress - being worked on
  doing,

  /// Done - completed
  done;

  String get value => name;

  String get displayName {
    switch (this) {
      case ItemState.todo:
        return 'Yapılacak';
      case ItemState.doing:
        return 'Yapılıyor';
      case ItemState.done:
        return 'Tamamlandı';
    }
  }

  String get emoji {
    switch (this) {
      case ItemState.todo:
        return '📋';
      case ItemState.doing:
        return '🔄';
      case ItemState.done:
        return '✅';
    }
  }

  static ItemState fromString(String value) {
    return ItemState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ItemState.todo,
    );
  }
}

/// Item priority
enum ItemPriority {
  low,
  medium,
  high;

  String get value => name;

  String get displayName {
    switch (this) {
      case ItemPriority.low:
        return 'Düşük';
      case ItemPriority.medium:
        return 'Orta';
      case ItemPriority.high:
        return 'Yüksek';
    }
  }

  String get emoji {
    switch (this) {
      case ItemPriority.low:
        return '🔵';
      case ItemPriority.medium:
        return '🟡';
      case ItemPriority.high:
        return '🔴';
    }
  }

  static ItemPriority fromString(String value) {
    return ItemPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ItemPriority.medium,
    );
  }
}

/// Item model - stored at /workspaces/{workspaceId}/items/{itemId}
class Item {
  final String id;
  final String workspaceId;
  final ItemType type;
  final String title;
  final String? description;
  final String? assigneeUserId;
  final ItemState state;
  final ItemPriority priority;
  final List<String> tags;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Item({
    required this.id,
    required this.workspaceId,
    required this.type,
    required this.title,
    this.description,
    this.assigneeUserId,
    required this.state,
    this.priority = ItemPriority.medium,
    this.tags = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String workspaceId,
  ) {
    final data = doc.data()!;
    return Item(
      id: doc.id,
      workspaceId: workspaceId,
      type: ItemType.fromString(data['type'] as String),
      title: data['title'] as String,
      description: data['description'] as String?,
      assigneeUserId: data['assigneeUserId'] as String?,
      state: ItemState.fromString(data['state'] as String),
      priority: ItemPriority.fromString(data['priority'] as String? ?? 'medium'),
      tags: List<String>.from(data['tags'] as List? ?? []),
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.value,
      'title': title,
      'description': description,
      'assigneeUserId': assigneeUserId,
      'state': state.value,
      'priority': priority.value,
      'tags': tags,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Item copyWith({
    String? id,
    String? workspaceId,
    ItemType? type,
    String? title,
    String? description,
    String? assigneeUserId,
    bool clearAssignee = false,
    ItemState? state,
    ItemPriority? priority,
    List<String>? tags,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeUserId: clearAssignee ? null : (assigneeUserId ?? this.assigneeUserId),
      state: state ?? this.state,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if item is assigned to someone
  bool get isAssigned => assigneeUserId != null;

  /// Check if item is completed
  bool get isCompleted => state == ItemState.done;

  /// Check if item is in progress
  bool get isInProgress => state == ItemState.doing;

  @override
  String toString() =>
      'Item(id: $id, title: $title, type: $type, state: $state)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
