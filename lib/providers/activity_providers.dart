import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

// Activity repository provider
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});

// ============================================
// Activity Stream Providers
// ============================================

/// Stream of recent activities for a workspace (last 50)
final recentActivitiesStreamProvider =
    StreamProvider.family<List<ItemActivity>, String>((ref, workspaceId) {
  final activityRepo = ref.read(activityRepositoryProvider);
  return activityRepo.watchRecentActivities(workspaceId);
});

/// Stream of activities for a specific item
final itemActivitiesStreamProvider =
    StreamProvider.family<List<ItemActivity>, ({String workspaceId, String itemId})>(
        (ref, params) {
  final activityRepo = ref.read(activityRepositoryProvider);
  return activityRepo.watchItemActivities(params.workspaceId, params.itemId);
});

// ============================================
// Activity Count (for badges)
// ============================================

/// Today's activity count for a workspace
final todayActivityCountProvider =
    FutureProvider.family<int, String>((ref, workspaceId) async {
  final activityRepo = ref.read(activityRepositoryProvider);
  return activityRepo.getTodayActivityCount(workspaceId);
});

// ============================================
// Activity Grouping Helpers
// ============================================

/// Group activities by date
class ActivityGroup {
  final String label;
  final List<ItemActivity> activities;

  const ActivityGroup({
    required this.label,
    required this.activities,
  });
}

/// Provider that groups activities by date
final groupedActivitiesProvider =
    Provider.family<List<ActivityGroup>, String>((ref, workspaceId) {
  final activitiesAsync = ref.watch(recentActivitiesStreamProvider(workspaceId));

  return activitiesAsync.when(
    data: (activities) => _groupByDate(activities),
    loading: () => [],
    error: (_, __) => [],
  );
});

List<ActivityGroup> _groupByDate(List<ItemActivity> activities) {
  if (activities.isEmpty) return [];

  final Map<String, List<ItemActivity>> grouped = {};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  for (final activity in activities) {
    final activityDate = DateTime(
      activity.createdAt.year,
      activity.createdAt.month,
      activity.createdAt.day,
    );

    String key;
    if (activityDate == today) {
      key = 'Bugün';
    } else if (activityDate == yesterday) {
      key = 'Dün';
    } else if (activityDate.isAfter(today.subtract(const Duration(days: 7)))) {
      key = 'Bu Hafta';
    } else {
      key = '${activityDate.day}/${activityDate.month}/${activityDate.year}';
    }

    grouped.putIfAbsent(key, () => []).add(activity);
  }

  // Convert to list in order
  final List<ActivityGroup> result = [];
  final orderedKeys = ['Bugün', 'Dün', 'Bu Hafta'];

  for (final key in orderedKeys) {
    if (grouped.containsKey(key)) {
      result.add(ActivityGroup(label: key, activities: grouped[key]!));
      grouped.remove(key);
    }
  }

  // Add remaining date keys (older dates)
  for (final entry in grouped.entries) {
    result.add(ActivityGroup(label: entry.key, activities: entry.value));
  }

  return result;
}

// ============================================
// Unread Activities (for notification badges)
// ============================================

/// Last seen activity timestamp (persisted locally - simplified version)
class ActivityNotifier extends StateNotifier<DateTime?> {
  ActivityNotifier() : super(null);

  void markAsSeen() {
    state = DateTime.now();
  }

  bool isUnread(ItemActivity activity) {
    if (state == null) return true;
    return activity.createdAt.isAfter(state!);
  }

  int countUnread(List<ItemActivity> activities) {
    if (state == null) return activities.length;
    return activities.where((a) => a.createdAt.isAfter(state!)).length;
  }
}

final activityNotifierProvider =
    StateNotifierProvider<ActivityNotifier, DateTime?>((ref) {
  return ActivityNotifier();
});

/// Count of unread activities
final unreadActivityCountProvider =
    Provider.family<int, String>((ref, workspaceId) {
  final activitiesAsync = ref.watch(recentActivitiesStreamProvider(workspaceId));
  final notifier = ref.watch(activityNotifierProvider.notifier);

  return activitiesAsync.when(
    data: (activities) => notifier.countUnread(activities),
    loading: () => 0,
    error: (_, __) => 0,
  );
});
