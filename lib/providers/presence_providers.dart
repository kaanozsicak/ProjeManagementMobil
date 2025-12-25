import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'auth_providers.dart';
import 'item_providers.dart';

// Presence repository provider
final presenceRepositoryProvider = Provider<PresenceRepository>((ref) {
  return PresenceRepository();
});

// ============================================
// Workspace Presence Providers
// ============================================

/// Stream of all presence data for a workspace
final workspacePresenceStreamProvider =
    StreamProvider.family<List<Presence>, String>((ref, workspaceId) {
  final presenceRepo = ref.watch(presenceRepositoryProvider);
  return presenceRepo.watchWorkspacePresence(workspaceId);
});

/// Presence map (userId -> Presence) for quick lookups
final presenceMapProvider =
    Provider.family<Map<String, Presence>, String>((ref, workspaceId) {
  final presenceAsync = ref.watch(workspacePresenceStreamProvider(workspaceId));
  return presenceAsync.when(
    data: (list) => {for (final p in list) p.userId: p},
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Get presence for a specific user in workspace
final userPresenceProvider =
    Provider.family<Presence?, ({String workspaceId, String userId})>(
        (ref, params) {
  final presenceMap = ref.watch(presenceMapProvider(params.workspaceId));
  return presenceMap[params.userId];
});

/// Current user's presence in a workspace
/// Combines stream data with notifier's local state for immediate updates
final myPresenceProvider =
    Provider.family<Presence?, String>((ref, workspaceId) {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUserId;
  if (userId == null) return null;

  // First check notifier's local state (for immediate updates after user action)
  final notifierState = ref.watch(presenceNotifierProvider(workspaceId));
  if (notifierState.currentPresence != null) {
    return notifierState.currentPresence;
  }

  // Fallback to stream data (for other users' changes or initial load)
  final presenceMap = ref.watch(presenceMapProvider(workspaceId));
  return presenceMap[userId];
});

// ============================================
// Presence State Notifier
// ============================================

class PresenceState {
  final bool isLoading;
  final String? error;
  final Presence? currentPresence;

  const PresenceState({
    this.isLoading = false,
    this.error,
    this.currentPresence,
  });

  PresenceState copyWith({
    bool? isLoading,
    String? error,
    Presence? currentPresence,
  }) {
    return PresenceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPresence: currentPresence ?? this.currentPresence,
    );
  }
}

class PresenceNotifier extends StateNotifier<PresenceState> {
  final PresenceRepository _presenceRepo;
  final String _workspaceId;
  final String? _currentUserId;

  PresenceNotifier(this._presenceRepo, this._workspaceId, this._currentUserId)
      : super(const PresenceState()) {
    _loadCurrentPresence();
  }

  Future<void> _loadCurrentPresence() async {
    if (_currentUserId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final presence = await _presenceRepo.getPresence(
        _workspaceId,
        _currentUserId!,
      );
      state = state.copyWith(
        isLoading: false,
        currentPresence: presence,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Durum yüklenemedi: $e',
      );
    }
  }

  /// Update status and message
  Future<bool> updatePresence({
    required PresenceStatus status,
    String? message,
  }) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'Kullanıcı girişi gerekli');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final presence = await _presenceRepo.updatePresence(
        workspaceId: _workspaceId,
        userId: _currentUserId!,
        status: status,
        message: message,
      );
      state = state.copyWith(
        isLoading: false,
        currentPresence: presence,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Durum güncellenemedi: $e',
      );
      return false;
    }
  }

  /// Quick status change
  Future<bool> setStatus(PresenceStatus status) async {
    if (_currentUserId == null) return false;

    try {
      await _presenceRepo.updateStatus(_workspaceId, _currentUserId!, status);
      final current = state.currentPresence;
      state = state.copyWith(
        currentPresence: current?.copyWith(status: status) ??
            Presence(
              workspaceId: _workspaceId,
              userId: _currentUserId!,
              status: status,
              updatedAt: DateTime.now(),
            ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Durum değiştirilemedi: $e');
      return false;
    }
  }

  /// Set status message
  Future<bool> setMessage(String? message) async {
    if (_currentUserId == null) return false;

    try {
      await _presenceRepo.updateMessage(_workspaceId, _currentUserId!, message);
      final current = state.currentPresence;
      if (current != null) {
        state = state.copyWith(
          currentPresence:
              current.copyWith(message: message, clearMessage: message == null),
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Mesaj güncellenemedi: $e');
      return false;
    }
  }

  /// Set as active with item title
  Future<bool> setActiveWithItem(String itemTitle) async {
    return updatePresence(
      status: PresenceStatus.active,
      message: itemTitle,
    );
  }

  /// Set as idle
  Future<bool> setIdle() async {
    return updatePresence(
      status: PresenceStatus.idle,
      message: null,
    );
  }

  /// Set as busy
  Future<bool> setBusy([String? reason]) async {
    return updatePresence(
      status: PresenceStatus.busy,
      message: reason,
    );
  }

  /// Set as away
  Future<bool> setAway([String? reason]) async {
    return updatePresence(
      status: PresenceStatus.away,
      message: reason,
    );
  }

  /// Ensure presence record exists without overriding current status
  Future<void> ensurePresenceExists() async {
    if (_currentUserId == null) return;
    
    // Check if presence already exists in state
    if (state.currentPresence != null) return;
    
    // Try to load from Firestore
    try {
      final existingPresence = await _presenceRepo.getPresence(
        _workspaceId,
        _currentUserId!,
      );
      
      if (existingPresence != null) {
        // Presence exists, just update state
        state = state.copyWith(currentPresence: existingPresence);
      } else {
        // No presence exists, create with idle status
        await updatePresence(
          status: PresenceStatus.idle,
          message: null,
        );
      }
    } catch (e) {
      // If error, try to create new presence
      await updatePresence(
        status: PresenceStatus.idle,
        message: null,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for presence operations in a workspace
final presenceNotifierProvider =
    StateNotifierProvider.family<PresenceNotifier, PresenceState, String>(
        (ref, workspaceId) {
  final presenceRepo = ref.watch(presenceRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  return PresenceNotifier(presenceRepo, workspaceId, authService.currentUserId);
});

// ============================================
// Active Users View (Doing items grouped by user with presence)
// ============================================

/// Data class for user with their active items and presence
class ActiveUserData {
  final String userId;
  final Presence? presence;
  final List<Item> activeItems;

  const ActiveUserData({
    required this.userId,
    this.presence,
    required this.activeItems,
  });

  bool get hasActiveItems => activeItems.isNotEmpty;
  int get activeItemCount => activeItems.length;
}

/// Provider for active users view (presence + doing items)
final activeUsersViewProvider =
    Provider.family<List<ActiveUserData>, String>((ref, workspaceId) {
  final presenceMap = ref.watch(presenceMapProvider(workspaceId));
  final membersAsync = ref.watch(workspaceMembersProvider(workspaceId));

  // Import from item_providers
  final activeItemsByUser = ref.watch(activeItemsByUserProvider(workspaceId));

  return membersAsync.when(
    data: (members) {
      final List<ActiveUserData> result = [];

      for (final member in members) {
        final userId = member.userId;
        final presence = presenceMap[userId];
        final items = activeItemsByUser[userId] ?? [];

        result.add(ActiveUserData(
          userId: userId,
          presence: presence,
          activeItems: items,
        ));
      }

      // Sort: users with presence first, then by status
      result.sort((a, b) {
        // Users with presence first
        if (a.presence != null && b.presence == null) return -1;
        if (a.presence == null && b.presence != null) return 1;

        // Then by active items count
        return b.activeItemCount.compareTo(a.activeItemCount);
      });

      return result;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
