import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';
import 'auth_providers.dart';

// Workspace list provider
final workspaceListProvider =
    StateNotifierProvider<WorkspaceListNotifier, WorkspaceListState>((ref) {
  final workspaceRepo = ref.watch(workspaceRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  return WorkspaceListNotifier(workspaceRepo, authService);
});

class WorkspaceListState {
  final bool isLoading;
  final String? error;
  final List<Workspace> workspaces;

  const WorkspaceListState({
    this.isLoading = false,
    this.error,
    this.workspaces = const [],
  });

  WorkspaceListState copyWith({
    bool? isLoading,
    String? error,
    List<Workspace>? workspaces,
  }) {
    return WorkspaceListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      workspaces: workspaces ?? this.workspaces,
    );
  }
}

class WorkspaceListNotifier extends StateNotifier<WorkspaceListState> {
  final WorkspaceRepository _workspaceRepo;
  final AuthService _authService;

  WorkspaceListNotifier(this._workspaceRepo, this._authService)
      : super(const WorkspaceListState());

  Future<void> loadWorkspaces() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'Kullanıcı oturumu bulunamadı');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final workspaces = await _workspaceRepo.getUserWorkspaces(userId);
      state = WorkspaceListState(workspaces: workspaces);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Workspaces yüklenemedi: ${e.toString()}',
      );
    }
  }

  Future<Workspace?> createWorkspace(String name) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'Kullanıcı oturumu bulunamadı');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final workspace = await _workspaceRepo.createWorkspace(
        name: name,
        createdBy: userId,
      );

      state = state.copyWith(
        isLoading: false,
        workspaces: [...state.workspaces, workspace],
      );

      return workspace;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Workspace oluşturulamadı: ${e.toString()}',
      );
      return null;
    }
  }
}

// Stream-based workspace list (alternative)
final workspaceStreamProvider = StreamProvider<List<Workspace>>((ref) {
  final workspaceRepo = ref.watch(workspaceRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUserId;

  if (userId == null) {
    return Stream.value([]);
  }

  return workspaceRepo.watchUserWorkspaces(userId);
});

// Create workspace provider
final createWorkspaceProvider =
    StateNotifierProvider<CreateWorkspaceNotifier, CreateWorkspaceState>((ref) {
  final workspaceRepo = ref.watch(workspaceRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  return CreateWorkspaceNotifier(workspaceRepo, authService);
});

class CreateWorkspaceState {
  final bool isLoading;
  final String? error;
  final Workspace? createdWorkspace;
  final WorkspaceInvite? invite;

  const CreateWorkspaceState({
    this.isLoading = false,
    this.error,
    this.createdWorkspace,
    this.invite,
  });

  CreateWorkspaceState copyWith({
    bool? isLoading,
    String? error,
    Workspace? createdWorkspace,
    WorkspaceInvite? invite,
  }) {
    return CreateWorkspaceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      createdWorkspace: createdWorkspace ?? this.createdWorkspace,
      invite: invite ?? this.invite,
    );
  }
}

class CreateWorkspaceNotifier extends StateNotifier<CreateWorkspaceState> {
  final WorkspaceRepository _workspaceRepo;
  final AuthService _authService;

  CreateWorkspaceNotifier(this._workspaceRepo, this._authService)
      : super(const CreateWorkspaceState());

  Future<bool> createWorkspaceWithInvite(String name) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'Kullanıcı oturumu bulunamadı');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Create workspace
      final workspace = await _workspaceRepo.createWorkspace(
        name: name,
        createdBy: userId,
      );

      // Create invite
      final invite = await _workspaceRepo.createInvite(
        workspaceId: workspace.id,
        createdBy: userId,
      );

      state = CreateWorkspaceState(
        createdWorkspace: workspace,
        invite: invite,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Workspace oluşturulamadı: ${e.toString()}',
      );
      return false;
    }
  }

  void reset() {
    state = const CreateWorkspaceState();
  }
}

// Join workspace provider
final joinWorkspaceProvider =
    StateNotifierProvider<JoinWorkspaceNotifier, JoinWorkspaceState>((ref) {
  final workspaceRepo = ref.watch(workspaceRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  return JoinWorkspaceNotifier(workspaceRepo, authService);
});

class JoinWorkspaceState {
  final bool isLoading;
  final String? error;
  final Workspace? joinedWorkspace;
  final JoinResult? result;

  const JoinWorkspaceState({
    this.isLoading = false,
    this.error,
    this.joinedWorkspace,
    this.result,
  });

  JoinWorkspaceState copyWith({
    bool? isLoading,
    String? error,
    Workspace? joinedWorkspace,
    JoinResult? result,
  }) {
    return JoinWorkspaceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      joinedWorkspace: joinedWorkspace ?? this.joinedWorkspace,
      result: result ?? this.result,
    );
  }
}

enum JoinResult { success, invalidCode, expired, alreadyMember, maxUses }

class JoinWorkspaceNotifier extends StateNotifier<JoinWorkspaceState> {
  final WorkspaceRepository _workspaceRepo;
  final AuthService _authService;

  JoinWorkspaceNotifier(this._workspaceRepo, this._authService)
      : super(const JoinWorkspaceState());

  Future<bool> joinWithInvite(String inviteInput) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'Kullanıcı oturumu bulunamadı');
      return false;
    }

    // Parse invite
    final inviteData = InviteParser.parse(inviteInput);
    if (inviteData == null) {
      state = state.copyWith(
        error: 'Geçersiz davet kodu formatı',
        result: JoinResult.invalidCode,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Validate and use invite
      final result = await _workspaceRepo.validateAndUseInvite(
        workspaceId: inviteData.workspaceId,
        token: inviteData.token,
        userId: userId,
      );

      switch (result) {
        case InviteValidationResult.success:
          final workspace =
              await _workspaceRepo.getWorkspace(inviteData.workspaceId);
          state = JoinWorkspaceState(
            joinedWorkspace: workspace,
            result: JoinResult.success,
          );
          return true;

        case InviteValidationResult.notFound:
          state = state.copyWith(
            isLoading: false,
            error: 'Davet kodu bulunamadı',
            result: JoinResult.invalidCode,
          );
          return false;

        case InviteValidationResult.expired:
          state = state.copyWith(
            isLoading: false,
            error: 'Davet kodunun süresi dolmuş',
            result: JoinResult.expired,
          );
          return false;

        case InviteValidationResult.maxUsesReached:
          state = state.copyWith(
            isLoading: false,
            error: 'Davet kodu kullanım limitine ulaşmış',
            result: JoinResult.maxUses,
          );
          return false;

        case InviteValidationResult.alreadyMember:
          final workspace =
              await _workspaceRepo.getWorkspace(inviteData.workspaceId);
          state = state.copyWith(
            isLoading: false,
            error: 'Zaten bu workspace\'e üyesiniz',
            joinedWorkspace: workspace,
            result: JoinResult.alreadyMember,
          );
          return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Katılım başarısız: ${e.toString()}',
      );
      return false;
    }
  }

  void reset() {
    state = const JoinWorkspaceState();
  }
}
