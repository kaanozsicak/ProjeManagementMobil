import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/providers.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/workspace_list/workspace_list_screen.dart';
import 'ui/create_workspace/create_workspace_screen.dart';
import 'ui/join_workspace/join_workspace_screen.dart';
import 'ui/workspace_home/workspace_home_screen.dart';
import 'ui/board/board_screen.dart';
import 'ui/activity/activity_log_screen.dart';

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
      // Splash route
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),

      // Onboarding route
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Workspace list route
      GoRoute(
        path: '/workspaces',
        builder: (context, state) => const WorkspaceListScreen(),
      ),

      // Create workspace route
      GoRoute(
        path: '/create',
        builder: (context, state) => const CreateWorkspaceScreen(),
      ),

      // Join workspace route
      GoRoute(
        path: '/join',
        builder: (context, state) => const JoinWorkspaceScreen(),
      ),

      // Workspace home route
      GoRoute(
        path: '/workspace/:id',
        builder: (context, state) {
          final workspaceId = state.pathParameters['id']!;
          return WorkspaceHomeScreen(workspaceId: workspaceId);
        },
      ),

      // Board route (Phase 2)
      GoRoute(
        path: '/workspace/:id/board',
        builder: (context, state) {
          final workspaceId = state.pathParameters['id']!;
          return BoardScreen(workspaceId: workspaceId);
        },
      ),

      // Activity log route (Phase 4)
      GoRoute(
        path: '/workspace/:id/activities',
        builder: (context, state) {
          final workspaceId = state.pathParameters['id']!;
          return ActivityLogScreen(workspaceId: workspaceId);
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
