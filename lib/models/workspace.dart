import 'package:cloud_firestore/cloud_firestore.dart';

/// Workspace model - stored at /workspaces/{workspaceId}
class Workspace {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;

  const Workspace({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  factory Workspace.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Workspace(
      id: doc.id,
      name: data['name'] as String? ?? 'Unnamed',
      createdBy: data['createdBy'] as String? ?? data['ownerId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Workspace copyWith({
    String? id,
    String? name,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Workspace(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Workspace &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
