import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/main_scaffold.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/conversations/conversations_screen.dart';
import '../screens/todo/todo_screen.dart';
import '../screens/people/people_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/onboarding/onboarding_wizard.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/games/games_screen.dart';
import '../screens/settings/government_schemes_screen.dart';
import '../screens/settings/autopilot_screen.dart';
import '../screens/settings/subscription_screen.dart';
import '../screens/settings/team_screen.dart';
import '../screens/settings/custom_fields_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _dashboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final GlobalKey<NavigatorState> _conversationsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'conversations');
final GlobalKey<NavigatorState> _todoNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'todo');
final GlobalKey<NavigatorState> _peopleNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'people');
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

final goRouter = GoRouter(
  initialLocation: '/splash',
  navigatorKey: _rootNavigatorKey,
  redirect: (context, state) {
    // Cannot await inside redirect directly without complicated listenables.
    // Instead we will handle onboarding redirect inside the Dashboard screen's initState.
    return null;
  },
  routes: [
    // ── Splash Screen (Initialization boundary) ────────────────────────────
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ── Onboarding (full-screen, no bottom nav) ────────────────────────────
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingWizard(
        onComplete: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_complete', true);
          if (context.mounted) context.go('/dashboard');
        },
      ),
    ),

    // ── Sidebar-only screens (no bottom nav) ──────────────────────────────
    GoRoute(
      path: '/government-schemes',
      builder: (_, __) => const _ScreenShell(title: '🏛 Govt. Schemes', child: GovernmentSchemesScreen()),
    ),
    GoRoute(
      path: '/autopilot',
      builder: (_, __) => const _ScreenShell(title: '⚡ Autopilot', child: AutopilotScreen()),
    ),
    GoRoute(
      path: '/subscription',
      builder: (_, __) => const _ScreenShell(title: '💎 Subscription', child: SubscriptionScreen()),
    ),
    GoRoute(
      path: '/custom-fields',
      builder: (_, __) => const _ScreenShell(title: '⚙️ Custom Fields', child: CustomFieldsScreen()),
    ),
    GoRoute(
      path: '/games',
      builder: (_, __) => const _ScreenShell(title: '🎮 Games & Badges', child: GamesScreen()),
    ),
    GoRoute(
      path: '/team',
      builder: (_, __) => const _ScreenShell(title: '👥 Team Management', child: TeamScreen()),
    ),
    GoRoute(
      path: '/seats',
      builder: (_, __) => const _ScreenShell(title: '🪑 Seat Management', child: TeamScreen()),
    ),
    GoRoute(
      path: '/invite',
      builder: (_, __) => const _ScreenShell(title: '✉️ Invite Member', child: TeamScreen()),
    ),
    GoRoute(
      path: '/badges',
      builder: (_, __) => const _ScreenShell(title: '🏆 Badges', child: GamesScreen(initialTab: 1)),
    ),

    // ── Main shell with bottom navigation ────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _dashboardNavigatorKey,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _conversationsNavigatorKey,
          routes: [
            GoRoute(
              path: '/conversations',
              builder: (context, state) => const ConversationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _todoNavigatorKey,
          routes: [
            GoRoute(
              path: '/todo',
              builder: (context, state) => const TodoScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _peopleNavigatorKey,
          routes: [
            GoRoute(
              path: '/people',
              builder: (context, state) => const PeopleScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Simple scaffold wrapper for sidebar-only full screens
class _ScreenShell extends StatelessWidget {
  final String title;
  final Widget child;
  const _ScreenShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: child,
    );
  }
}
