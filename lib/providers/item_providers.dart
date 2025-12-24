import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'auth_providers.dart';
import 'activity_providers.dart';

// Item repository provider
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository();
});

// ============================================
// Board Items Provider (Real-time stream)
// ============================================

/// Stream of all items for a workspace (excluding completed)
final boardItemsStreamProvider =
    StreamProvider.family<List<Item>, String>((ref, workspaceId) {
  final itemRepo = ref.watch(itemRepositoryProvider);
  return itemRepo.watchBoardItems(workspaceId);
});

/// Stream of all items including completed
final allItemsStreamProvider =
    StreamProvider.family<List<Item>, String>((ref, workspaceId) {
  final itemRepo = ref.watch(itemRepositoryProvider);
  return itemRepo.watchWorkspaceItems(workspaceId);
});

/// Stream of completed items only
final completedItemsStreamProvider =
    StreamProvider.family<List<Item>, String>((ref, workspaceId) {
  final itemRepo = ref.watch(itemRepositoryProvider);
  return itemRepo.watchCompletedItems(workspaceId);
});

// ============================================
// Board Sections (Computed from items)
// ============================================

/// Board section data holder
class BoardSection {
  final ItemType type;
  final String title;
  final String emoji;
  final List<Item> items;

  const BoardSection({
    required this.type,
    required this.title,
    required this.emoji,
    required this.items,
  });

  bool get isEmpty => items.isEmpty;
  int get count => items.length;
}

/// Provider that groups items by type for board sections
final boardSectionsProvider =
    Provider.family<List<BoardSection>, String>((ref, workspaceId) {
  final itemsAsync = ref.watch(boardItemsStreamProvider(workspaceId));

  return itemsAsync.when(
    data: (items) {
      // Group items by type
      final Map<ItemType, List<Item>> grouped = {};
      for (final type in ItemType.values) {
        grouped[type] = [];
      }
      for (final item in items) {
        grouped[item.type]!.add(item);
      }

      // Create board sections in order
      return [
        BoardSection(
          type: ItemType.activeTask,
          title: 'Active / Şu Anda',
          emoji: '🎯',
          items: grouped[ItemType.activeTask]!,
        ),
        BoardSection(
          type: ItemType.bug,
          title: 'Bug & Veri Hataları',
          emoji: '🐛',
          items: grouped[ItemType.bug]!,
        ),
        BoardSection(
          type: ItemType.logic,
          title: 'Logic & Refactoring',
          emoji: '⚙️',
          items: grouped[ItemType.logic]!,
        ),
        BoardSection(
          type: ItemType.idea,
          title: 'Fikir Kutusu',
          emoji: '💡',
          items: grouped[ItemType.idea]!,
        ),
      ];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ============================================
// Active Items (Doing state, grouped by user)
// ============================================

/// Items currently being worked on (doing state)
final activeItemsProvider =
    Provider.family<List<Item>, String>((ref, workspaceId) {
  final itemsAsync = ref.watch(boardItemsStreamProvider(workspaceId));

  return itemsAsync.when(
    data: (items) => items.where((i) => i.state == ItemState.doing).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Active items grouped by assignee
final activeItemsByUserProvider =
    Provider.family<Map<String?, List<Item>>, String>((ref, workspaceId) {
  final activeItems = ref.watch(activeItemsProvider(workspaceId));

  final Map<String?, List<Item>> grouped = {};
  for (final item in activeItems) {
    grouped.putIfAbsent(item.assigneeUserId, () => []).add(item);
  }
  return grouped;
});

// ============================================
// Item CRUD State Notifier
// ============================================

class ItemState2 {
  final bool isLoading;
  final String? error;
  final Item? lastCreatedItem;

  const ItemState2({
    this.isLoading = false,
    this.error,
    this.lastCreatedItem,
  });

  ItemState2 copyWith({
    bool? isLoading,
    String? error,
    Item? lastCreatedItem,
  }) {
    return ItemState2(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastCreatedItem: lastCreatedItem ?? this.lastCreatedItem,
    );
  }
}

class ItemNotifier extends StateNotifier<ItemState2> {
  final ItemRepository _itemRepo;
  final ActivityRepository _activityRepo;
  final String _workspaceId;
  final String? _currentUserId;
  final String _currentUserName;

  ItemNotifier(this._itemRepo, this._activityRepo, this._workspaceId, this._currentUserId, this._currentUserName)
      : super(const ItemState2());

  /// Create a new item
  Future<Item?> createItem({
    required ItemType type,
    required String title,
    String? description,
    String? assigneeUserId,
    ItemState initialState = ItemState.todo,
    ItemPriority priority = ItemPriority.medium,
    List<String> tags = const [],
  }) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'Kullanıcı girişi gerekli');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final item = await _itemRepo.createItem(
        workspaceId: _workspaceId,
        type: type,
        title: title,
        description: description,
        assigneeUserId: assigneeUserId,
        state: initialState,
        priority: priority,
        tags: tags,
        createdBy: _currentUserId!,
      );

      // Log activity
      await _activityRepo.logItemCreated(
        workspaceId: _workspaceId,
        item: item,
        actorUserId: _currentUserId!,
        actorName: _currentUserName,
      );

      state = state.copyWith(isLoading: false, lastCreatedItem: item);
      return item;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Item oluşturulamadı: $e');
      return null;
    }
  }

  /// Update an existing item
  Future<bool> updateItem(Item item) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _itemRepo.updateItem(item);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Item güncellenemedi: $e');
      return false;
    }
  }

  /// Delete an item
  Future<bool> deleteItem(String itemId, {String? itemTitle}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _itemRepo.deleteItem(_workspaceId, itemId);
      
      // Log activity
      if (_currentUserId != null) {
        await _activityRepo.logItemDeleted(
          workspaceId: _workspaceId,
          itemId: itemId,
          itemTitle: itemTitle ?? 'Item',
          actorUserId: _currentUserId!,
          actorName: _currentUserName,
        );
      }
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Item silinemedi: $e');
      return false;
    }
  }

  /// Change item state (todo -> doing -> done)
  Future<bool> changeState(String itemId, ItemState newState, {String? itemTitle, ItemState? oldState}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _itemRepo.updateItemState(_workspaceId, itemId, newState);
      
      // Log activity
      if (_currentUserId != null) {
        await _activityRepo.logStateChanged(
          workspaceId: _workspaceId,
          itemId: itemId,
          itemTitle: itemTitle ?? 'Item',
          actorUserId: _currentUserId!,
          actorName: _currentUserName,
          oldState: oldState ?? ItemState.todo,
          newState: newState,
        );
      }
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Durum değiştirilemedi: $e');
      return false;
    }
  }

  /// Assign item to a user
  Future<bool> assignTo(String itemId, String? userId, {String? itemTitle, String? assigneeName}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _itemRepo.assignItem(_workspaceId, itemId, userId);
      
      // Log activity
      if (_currentUserId != null) {
        await _activityRepo.logItemAssigned(
          workspaceId: _workspaceId,
          itemId: itemId,
          itemTitle: itemTitle ?? 'Item',
          actorUserId: _currentUserId!,
          actorName: _currentUserName,
          assigneeUserId: userId,
          assigneeName: assigneeName,
        );
      }
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Atama yapılamadı: $e');
      return false;
    }
  }

  /// Take item (assign to current user)
  Future<bool> takeItem(String itemId) async {
    return assignTo(itemId, _currentUserId);
  }

  /// Convert idea to task/bug/logic
  Future<bool> convertType(String itemId, ItemType newType, {String? itemTitle, ItemType? oldType}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _itemRepo.convertItemType(_workspaceId, itemId, newType);
      
      // Log activity
      if (_currentUserId != null) {
        await _activityRepo.logTypeChanged(
          workspaceId: _workspaceId,
          itemId: itemId,
          itemTitle: itemTitle ?? 'Item',
          actorUserId: _currentUserId!,
          actorName: _currentUserName,
          oldType: oldType ?? ItemType.idea,
          newType: newType,
        );
      }
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Tür değiştirilemedi: $e');
      return false;
    }
  }

  /// Mark item as done
  Future<bool> markAsDone(String itemId, {String? itemTitle, ItemState? oldState}) async {
    return changeState(itemId, ItemState.done, itemTitle: itemTitle, oldState: oldState);
  }

  /// Start working on item (move to doing)
  Future<bool> startWorking(String itemId, {String? itemTitle, ItemState? oldState}) async {
    return changeState(itemId, ItemState.doing, itemTitle: itemTitle, oldState: oldState);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for item operations in a workspace
final itemNotifierProvider =
    StateNotifierProvider.family<ItemNotifier, ItemState2, String>(
        (ref, workspaceId) {
  final itemRepo = ref.watch(itemRepositoryProvider);
  final activityRepo = ref.watch(activityRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  final currentUserName = authService.currentUser?.displayName ?? 'Anonim';
  return ItemNotifier(
    itemRepo, 
    activityRepo, 
    workspaceId, 
    authService.currentUserId,
    currentUserName,
  );
});

// ============================================
// Workspace Members (for assignment dropdown)
// ============================================

/// Stream of workspace members for assignment
final workspaceMembersProvider =
    FutureProvider.family<List<Membership>, String>((ref, workspaceId) async {
  final workspaceRepo = ref.watch(workspaceRepositoryProvider);
  return workspaceRepo.getWorkspaceMembers(workspaceId);
});
