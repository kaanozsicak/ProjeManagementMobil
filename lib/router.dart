import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/providers.dart';
import 'shared/theme/app_motion.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/workspace_list/workspace_list_screen.dart';
import 'ui/create_workspace/create_workspace_screen.dart';
import 'ui/join_workspace/join_workspace_screen.dart';
import 'ui/workspace_home/workspace_home_screen.dart';
import 'ui/board/board_screen.dart';
import 'ui/activity/activity_log_screen.dart';

// ============================================
// Page Transition Builders
// ============================================

/// Minimal fade transition for splash screen
CustomTransitionPage<void> _buildFadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: AppMotion.durationFast,
    reverseTransitionDuration: AppMotion.durationSm,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: AppMotion.curveDecelerate,
        ),
        child: child,
      );
    },
  );
}

/// Standard slide + fade transition for most pages
CustomTransitionPage<void> _buildSlideFadePage({
  required LocalKey key,
  required Widget child,
  bool isEmphasized = false,
}) {
  final duration = isEmphasized 
      ? AppMotion.durationMedium 
      : AppMotion.durationFast;
  
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Primary animation (entering)
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AppMotion.curveDecelerate,
        reverseCurve: AppMotion.curveAccelerate,
      );
      
      // Secondary animation (when another page pushes on top)
      final secondaryCurvedAnimation = CurvedAnimation(
        parent: secondaryAnimation,
        curve: AppMotion.curveAccelerate,
        reverseCurve: AppMotion.curveDecelerate,
      );

      // Slide from right (push) / slide to right (pop)
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.15, 0),
        end: Offset.zero,
      ).animate(curvedAnimation);

      // Fade in/out
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(curvedAnimation);

      // When a new page pushes on top, slightly slide and fade out
      final secondarySlideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.05, 0),
      ).animate(secondaryCurvedAnimation);

      final secondaryFadeAnimation = Tween<double>(
        begin: 1.0,
        end: 0.92,
      ).animate(secondaryCurvedAnimation);

      return SlideTransition(
        position: secondarySlideAnimation,
        child: FadeTransition(
          opacity: secondaryFadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

/// Modal-style slide up transition for dialogs/sheets
CustomTransitionPage<void> _buildSlideUpPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: AppMotion.durationMedium,
    reverseTransitionDuration: AppMotion.durationFast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AppMotion.curveDecelerate,
        reverseCurve: AppMotion.curveAccelerate,
      );

      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(curvedAnimation);

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(curvedAnimation);

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isOnSplash = state.matchedLocation == '/splash';
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      // If on splash, check auth state
      if (isOnSplash) {
        if (isLoggedIn) {
          return '/workspaces';
        } else {
          return '/onboarding';
        }
      }

      // If not logged in and not on onboarding, redirect to onboarding
      if (!isLoggedIn && !isOnOnboarding) {
        return '/onboarding';
      }

      // If logged in and on onboarding, redirect to workspaces
      if (isLoggedIn && isOnOnboarding) {
        return '/workspaces';
      }

      return null;
    },
    routes: [
      // Splash route - minimal fade
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _buildFadePage(
          key: state.pageKey,
          child: const _SplashScreen(),
        ),
      ),

      // Onboarding route - emphasized transition
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildSlideFadePage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          isEmphasized: true,
        ),
      ),

      // Workspace list route
      GoRoute(
        path: '/workspaces',
        pageBuilder: (context, state) => _buildSlideFadePage(
          key: state.pageKey,
          child: const WorkspaceListScreen(),
        ),
      ),

      // Create workspace route - slide up (modal-like)
      GoRoute(
        path: '/create',
        pageBuilder: (context, state) => _buildSlideUpPage(
          key: state.pageKey,
          child: const CreateWorkspaceScreen(),
        ),
      ),

      // Join workspace route - slide up (modal-like)
      GoRoute(
        path: '/join',
        pageBuilder: (context, state) => _buildSlideUpPage(
          key: state.pageKey,
          child: const JoinWorkspaceScreen(),
        ),
      ),

      // Workspace home route
      GoRoute(
        path: '/workspace/:id',
        pageBuilder: (context, state) {
          final workspaceId = state.pathParameters['id']!;
          return _buildSlideFadePage(
            key: state.pageKey,
            child: WorkspaceHomeScreen(workspaceId: workspaceId),
          );
        },
      ),

      // Board route (Phase 2) - emphasized transition
      GoRoute(
        path: '/workspace/:id/board',
        pageBuilder: (context, state) {
          final workspaceId = state.pathParameters['id']!;
          return _buildSlideFadePage(
            key: state.pageKey,
            child: BoardScreen(workspaceId: workspaceId),
            isEmphasized: true,
          );
        },
      ),

      // Activity log route (Phase 4)
      GoRoute(
        path: '/workspace/:id/activities',
        pageBuilder: (context, state) {
          final workspaceId = state.pathParameters['id']!;
          return _buildSlideFadePage(
            key: state.pageKey,
            child: ActivityLogScreen(workspaceId: workspaceId),
          );
        },
      ),
    ],
  );
});

/// Simple splash screen for initial loading
class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final authService = ref.read(authServiceProvider);

    if (authService.isSignedIn) {
      final hasProfile = await authService.hasUserProfile();
      if (hasProfile) {
        final user = await authService.getCurrentUserProfile();
        if (user != null && mounted) {
          ref.read(authStateProvider.notifier).signInWithUsername(user.displayName);
        }
      } else {
        if (mounted) {
          context.go('/onboarding');
        }
      }
    } else {
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Kim Ne Yaptı?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
