import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../repositories/repositories.dart';

// Repository providers
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return WorkspaceRepository();
});

// Service providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    userRepository: ref.watch(userRepositoryProvider),
  );
});

// Auth state providers
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(firebaseAuthStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      final userRepo = ref.read(userRepositoryProvider);
      return await userRepo.getUser(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final currentUserStreamProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).watchCurrentUserProfile();
});

// Auth state notifier for login/logout actions
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.watch(authServiceProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;
  final AppUser? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    AppUser? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    if (_authService.isSignedIn) {
      final user = await _authService.getCurrentUserProfile();
      state = state.copyWith(user: user);
    }
  }

  Future<bool> signInWithUsername(String displayName) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.signInWithUsername(displayName);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Giriş yapılamadı: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState();
  }
}

// Check if user needs onboarding
final needsOnboardingProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);

  if (!authService.isSignedIn) {
    return true;
  }

  final hasProfile = await authService.hasUserProfile();
  return !hasProfile;
});
