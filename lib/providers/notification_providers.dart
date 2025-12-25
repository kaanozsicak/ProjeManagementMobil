import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/services.dart';
import '../repositories/repositories.dart';
import 'auth_providers.dart';

// ============================================
// Notification Service Provider
// ============================================

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ============================================
// Token Repository Provider
// ============================================

final tokenRepositoryProvider = Provider<TokenRepository>((ref) {
  return TokenRepository();
});

// ============================================
// Notification State Notifier
// ============================================

class NotificationState {
  final bool isInitialized;
  final String? fcmToken;
  final bool hasPermission;
  final String? error;

  const NotificationState({
    this.isInitialized = false,
    this.fcmToken,
    this.hasPermission = false,
    this.error,
  });

  NotificationState copyWith({
    bool? isInitialized,
    String? fcmToken,
    bool? hasPermission,
    String? error,
  }) {
    return NotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      fcmToken: fcmToken ?? this.fcmToken,
      hasPermission: hasPermission ?? this.hasPermission,
      error: error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;
  final TokenRepository _tokenRepo;
  final String? _userId;

  NotificationNotifier(this._service, this._tokenRepo, this._userId)
      : super(const NotificationState());

  /// Initialize notifications and save token
  Future<void> initialize() async {
    if (state.isInitialized) return;

    try {
      // Initialize notification service
      await _service.initialize();

      // Get FCM token
      final token = await _service.getToken();

      // Save token to Firestore
      if (token != null && _userId != null) {
        await _tokenRepo.saveToken(
          userId: _userId!,
          token: token,
        );
      }

      state = state.copyWith(
        isInitialized: true,
        fcmToken: token,
        hasPermission: true,
      );

      // Listen for token refresh
      _service.onTokenRefresh.listen((newToken) async {
        if (_userId != null) {
          // Delete old token if exists
          if (state.fcmToken != null) {
            await _tokenRepo.deleteToken(_userId!, state.fcmToken!);
          }
          // Save new token
          await _tokenRepo.saveToken(userId: _userId!, token: newToken);
          state = state.copyWith(fcmToken: newToken);
        }
      });
    } catch (e) {
      state = state.copyWith(
        isInitialized: false,
        error: 'Bildirim servisi başlatılamadı: $e',
      );
    }
  }

  /// Subscribe to a workspace's notifications
  Future<void> subscribeToWorkspace(String workspaceId) async {
    await _service.subscribeToWorkspace(workspaceId);
  }

  /// Unsubscribe from a workspace's notifications
  Future<void> unsubscribeFromWorkspace(String workspaceId) async {
    await _service.unsubscribeFromWorkspace(workspaceId);
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    if (_userId != null && state.fcmToken != null) {
      await _tokenRepo.deleteToken(_userId!, state.fcmToken!);
    }
    state = const NotificationState();
  }

  /// Show test notification
  Future<void> showTestNotification() async {
    await _service.showTestNotification();
  }
}

/// Provider for notification operations
final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  final tokenRepo = ref.watch(tokenRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  return NotificationNotifier(service, tokenRepo, authService.currentUserId);
});

/// Auto-initialize notifications when user logs in
final notificationInitializerProvider = FutureProvider<void>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  if (authState.user != null) {
    final notifier = ref.read(notificationNotifierProvider.notifier);
    await notifier.initialize();
  }
});
