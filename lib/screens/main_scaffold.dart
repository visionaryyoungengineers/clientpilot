import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_sidebar.dart';
import '../theme/app_colors.dart';
import '../services/streak_service.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainScaffold({super.key, required this.navigationShell});
  @override ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  StatefulNavigationShell get navigationShell => widget.navigationShell;

  String? _profilePhotoPath;
  String? _profileName;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _profilePhotoPath = prefs.getString('profile_photo_path');
        _profileName      = prefs.getString('profile_name');
      });
    }
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
    // Refresh profile photo when switching tabs
    _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final theme = Theme.of(context);

    final initials = (_profileName != null && _profileName!.isNotEmpty)
        ? _profileName!.trim().split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : '?';

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false, // Prevents double-keyboard shrinking crash with nested Scaffolds
      drawer: const AppSidebar(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Prominent Streak Counter
          Builder(builder: (context) {
            final streakCount = ref.watch(streakProvider);
            if (streakCount == 0) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orangeAccent.withAlpha(100)),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('$streakCount', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            );
          }),
          
          // Real profile photo avatar (or initials fallback)
          GestureDetector(
            onTap: _loadProfileData,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(80), width: 2),
                color: theme.colorScheme.primary.withAlpha(120),
                image: _profilePhotoPath != null
                    ? DecorationImage(
                        image: FileImage(File(_profilePhotoPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _profilePhotoPath == null
                  ? Center(
                      child: Text(
                        initials,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  : null,
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Colors.white, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient Hero — taller to give subtitle breathing room
          Positioned(
            top: 0, left: 0, right: 0,
            height: screenHeight * 0.32,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // ClientPilot Header Branding
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Client',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        const Text(
                          'Pilot',
                          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your business co-pilot ✈️',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Foreground Content — starts at 25% so subtitle is fully visible above
          Positioned.fill(
            top: screenHeight * 0.25,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: navigationShell,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            height: 65,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: theme.colorScheme.primary.withAlpha(30),
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            destinations: const [
              NavigationDestination(icon: Icon(LucideIcons.layoutDashboard, size: 22), selectedIcon: Icon(LucideIcons.layoutDashboard, size: 24), label: 'Home'),
              NavigationDestination(icon: Icon(LucideIcons.messageSquare, size: 22), selectedIcon: Icon(LucideIcons.messageSquare, size: 24), label: 'Chats'),
              NavigationDestination(icon: Icon(LucideIcons.squareCheck, size: 22), selectedIcon: Icon(LucideIcons.squareCheck, size: 24), label: 'To-Do'),
              NavigationDestination(icon: Icon(LucideIcons.users, size: 22), selectedIcon: Icon(LucideIcons.users, size: 24), label: 'People'),
              NavigationDestination(icon: Icon(LucideIcons.user, size: 22), selectedIcon: Icon(LucideIcons.user, size: 24), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
