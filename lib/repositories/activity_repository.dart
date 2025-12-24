import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'firestore_paths.dart';

/// Repository for activity-related Firestore operations
class ActivityRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  ActivityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = const Uuid();

  /// Get activities collection reference for a workspace
  CollectionReference<Map<String, dynamic>> _activitiesCollection(
    String workspaceId,
  ) {
    return _firestore.collection(FirestorePaths.workspaceActivities(workspaceId));
  }

  /// Log an activity
  Future<ItemActivity> logActivity({
    required String workspaceId,
    required String itemId,
    String? itemTitle,
    required ActivityAction action,
    required String actorUserId,
    required String actorName,
    Map<String, dynamic>? payload,
  }) async {
    final id = _uuid.v4();
    final activity = ItemActivity(
      id: id,
      workspaceId: workspaceId,
      itemId: itemId,
      itemTitle: itemTitle,
      action: action,
      actorUserId: actorUserId,
      actorName: actorName,
      payload: payload,
      createdAt: DateTime.now(),
    );

    await _activitiesCollection(workspaceId).doc(id).set(activity.toFirestore());
    return activity;
  }

  /// Log item created
  Future<void> logItemCreated({
    required String workspaceId,
    required Item item,
    required String actorUserId,
    required String actorName,
  }) async {
    await logActivity(
      workspaceId: workspaceId,
      itemId: item.id,
      itemTitle: item.title,
      action: ActivityAction.created,
      actorUserId: actorUserId,
      actorName: actorName,
      payload: {
        'type': item.type.displayName,
        'priority': item.priority.displayName,
      },
    );
  }

  /// Log item deleted
  Future<void> logItemDeleted({
    required String workspaceId,
    required String itemId,
    required String itemTitle,
    required String actorUserId,
    required String actorName,
  }) async {
    await logActivity(
      workspaceId: workspaceId,
      itemId: itemId,
      itemTitle: itemTitle,
      action: ActivityAction.deleted,
      actorUserId: actorUserId,
      actorName: actorName,
    );
  }

  /// Log item state changed
  Future<void> logStateChanged({
    required String workspaceId,
    required String itemId,
    required String itemTitle,
    required ItemState oldState,
    required ItemState newState,
    required String actorUserId,
    required String actorName,
  }) async {
    await logActivity(
      workspaceId: workspaceId,
      itemId: itemId,
      itemTitle: itemTitle,
      action: ActivityAction.stateChanged,
      actorUserId: actorUserId,
      actorName: actorName,
      payload: {
        'fromState': oldState.displayName,
        'toState': newState.displayName,
      },
    );
  }

  /// Log item assigned
  Future<void> logItemAssigned({
    required String workspaceId,
    required String itemId,
    required String itemTitle,
    required String actorUserId,
    required String actorName,
    String? assigneeUserId,
    String? assigneeName,
  }) async {
    final action = assigneeUserId != null 
        ? ActivityAction.assigned 
        : ActivityAction.unassigned;
    
    await logActivity(
      workspaceId: workspaceId,
      itemId: itemId,
      itemTitle: itemTitle,
      action: action,
      actorUserId: actorUserId,
      actorName: actorName,
      payload: {
        'assigneeUserId': assigneeUserId,
        'assigneeName': assigneeName,
      },
    );
  }

  /// Log item type changed
  Future<void> logTypeChanged({
    required String workspaceId,
    required String itemId,
    required String itemTitle,
    required ItemType oldType,
    required ItemType newType,
    required String actorUserId,
    required String actorName,
  }) async {
    await logActivity(
      workspaceId: workspaceId,
      itemId: itemId,
      itemTitle: itemTitle,
      action: ActivityAction.typeChanged,
      actorUserId: actorUserId,
      actorName: actorName,
      payload: {
        'fromType': oldType.displayName,
        'toType': newType.displayName,
      },
    );
  }

  /// Log item priority changed
  Future<void> logPriorityChanged({
    required String workspaceId,
    required String itemId,
    required String itemTitle,
    required ItemPriority oldPriority,
    required ItemPriority newPriority,
    required String actorUserId,
    required String actorName,
  }) async {
    await logActivity(
      workspaceId: workspaceId,
      itemId: itemId,
      itemTitle: itemTitle,
      action: ActivityAction.priorityChanged,
      actorUserId: actorUserId,
      actorName: actorName,
      payload: {
        'fromPriority': oldPriority.displayName,
        'toPriority': newPriority.displayName,
      },
    );
  }

  /// Log content edited (title or description)
  Future<void> logContentEdited({
    required String workspaceId,
    required String itemId,
    required String itemTitle,
    required String actorUserId,
    required String actorName,
    bool titleChanged = false,
    bool descriptionChanged = false,
  }) async {
    await logActivity(
      workspaceId: workspaceId,
      itemId: itemId,
      itemTitle: itemTitle,
      action: ActivityAction.contentEdited,
      actorUserId: actorUserId,
      actorName: actorName,
      payload: {
        'titleChanged': titleChanged,
        'descriptionChanged': descriptionChanged,
      },
    );
  }

  /// Get recent activities for a workspace
  Future<List<ItemActivity>> getRecentActivities(
    String workspaceId, {
    int limit = 50,
  }) async {
    final snapshot = await _activitiesCollection(workspaceId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ItemActivity.fromFirestore(doc, workspaceId))
        .toList();
  }

  /// Stream recent activities (real-time)
  Stream<List<ItemActivity>> watchRecentActivities(
    String workspaceId, {
    int limit = 50,
  }) {
    return _activitiesCollection(workspaceId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemActivity.fromFirestore(doc, workspaceId))
            .toList());
  }

  /// Get activities for a specific item
  Future<List<ItemActivity>> getItemActivities(
    String workspaceId,
    String itemId,
  ) async {
    final snapshot = await _activitiesCollection(workspaceId)
        .where('itemId', isEqualTo: itemId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ItemActivity.fromFirestore(doc, workspaceId))
        .toList();
  }

  /// Stream activities for a specific item
  Stream<List<ItemActivity>> watchItemActivities(
    String workspaceId,
    String itemId,
  ) {
    return _activitiesCollection(workspaceId)
        .where('itemId', isEqualTo: itemId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemActivity.fromFirestore(doc, workspaceId))
            .toList());
  }

  /// Get activity count for today (for badges)
  Future<int> getTodayActivityCount(String workspaceId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot = await _activitiesCollection(workspaceId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    return snapshot.docs.length;
  }
}
