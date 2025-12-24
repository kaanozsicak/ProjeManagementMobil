import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'firestore_paths.dart';

/// Repository for item-related Firestore operations
class ItemRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  ItemRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = const Uuid();

  /// Get items collection reference for a workspace
  CollectionReference<Map<String, dynamic>> _itemsCollection(
    String workspaceId,
  ) {
    return _firestore.collection(FirestorePaths.workspaceItems(workspaceId));
  }

  /// Get item document reference
  DocumentReference<Map<String, dynamic>> _itemDoc(
    String workspaceId,
    String itemId,
  ) {
    return _firestore.doc(FirestorePaths.item(workspaceId, itemId));
  }

  /// Create a new item
  Future<Item> createItem({
    required String workspaceId,
    required ItemType type,
    required String title,
    String? description,
    String? assigneeUserId,
    ItemState state = ItemState.todo,
    ItemPriority priority = ItemPriority.medium,
    List<String> tags = const [],
    required String createdBy,
  }) async {
    final itemId = _uuid.v4().substring(0, 8);
    final now = DateTime.now();

    final item = Item(
      id: itemId,
      workspaceId: workspaceId,
      type: type,
      title: title,
      description: description,
      assigneeUserId: assigneeUserId,
      state: state,
      priority: priority,
      tags: tags,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );

    await _itemsCollection(workspaceId).doc(itemId).set(item.toFirestore());
    return item;
  }

  /// Get item by ID
  Future<Item?> getItem(String workspaceId, String itemId) async {
    final doc = await _itemDoc(workspaceId, itemId).get();
    if (!doc.exists) return null;
    return Item.fromFirestore(doc, workspaceId);
  }

  /// Update an existing item
  Future<void> updateItem(Item item) async {
    final updatedItem = item.copyWith(updatedAt: DateTime.now());
    await _itemDoc(item.workspaceId, item.id).update(updatedItem.toFirestore());
  }

  /// Delete an item
  Future<void> deleteItem(String workspaceId, String itemId) async {
    await _itemDoc(workspaceId, itemId).delete();
  }

  /// Get all items for a workspace
  Future<List<Item>> getWorkspaceItems(String workspaceId) async {
    final snapshot = await _itemsCollection(workspaceId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Item.fromFirestore(doc, workspaceId))
        .toList();
  }

  /// Stream all items for a workspace (real-time updates)
  Stream<List<Item>> watchWorkspaceItems(String workspaceId) {
    return _itemsCollection(workspaceId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Item.fromFirestore(doc, workspaceId))
            .toList());
  }

  /// Get items by type
  Future<List<Item>> getItemsByType(
    String workspaceId,
    ItemType type,
  ) async {
    final snapshot = await _itemsCollection(workspaceId)
        .where('type', isEqualTo: type.value)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Item.fromFirestore(doc, workspaceId))
        .toList();
  }

  /// Get items by state
  Future<List<Item>> getItemsByState(
    String workspaceId,
    ItemState state,
  ) async {
    final snapshot = await _itemsCollection(workspaceId)
        .where('state', isEqualTo: state.value)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Item.fromFirestore(doc, workspaceId))
        .toList();
  }

  /// Get items assigned to a user
  Future<List<Item>> getItemsByAssignee(
    String workspaceId,
    String userId,
  ) async {
    final snapshot = await _itemsCollection(workspaceId)
        .where('assigneeUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Item.fromFirestore(doc, workspaceId))
        .toList();
  }

  /// Get active items (doing state) grouped by assignee
  Future<Map<String, List<Item>>> getActiveItemsGroupedByAssignee(
    String workspaceId,
  ) async {
    final items = await getItemsByState(workspaceId, ItemState.doing);
    final Map<String, List<Item>> grouped = {};

    for (final item in items) {
      final key = item.assigneeUserId ?? 'unassigned';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped;
  }

  /// Update item state
  Future<void> updateItemState(
    String workspaceId,
    String itemId,
    ItemState newState,
  ) async {
    await _itemDoc(workspaceId, itemId).update({
      'state': newState.value,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Assign item to a user
  Future<void> assignItem(
    String workspaceId,
    String itemId,
    String? assigneeUserId,
  ) async {
    await _itemDoc(workspaceId, itemId).update({
      'assigneeUserId': assigneeUserId,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Convert idea to another type (task/bug/logic)
  Future<void> convertItemType(
    String workspaceId,
    String itemId,
    ItemType newType,
  ) async {
    await _itemDoc(workspaceId, itemId).update({
      'type': newType.value,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Get completed items (for archive view)
  Future<List<Item>> getCompletedItems(String workspaceId) async {
    return getItemsByState(workspaceId, ItemState.done);
  }

  /// Stream completed items
  Stream<List<Item>> watchCompletedItems(String workspaceId) {
    return _itemsCollection(workspaceId)
        .where('state', isEqualTo: ItemState.done.value)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Item.fromFirestore(doc, workspaceId))
            .toList());
  }

  /// Get non-completed items for board view
  Stream<List<Item>> watchBoardItems(String workspaceId) {
    return _itemsCollection(workspaceId)
        .where('state', isNotEqualTo: ItemState.done.value)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Item.fromFirestore(doc, workspaceId))
            .toList());
  }
}
