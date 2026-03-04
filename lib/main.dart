import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'router/app_router.dart';
import 'widgets/startup_permissions_guard.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/celebration_service.dart';
import 'widgets/celebration_overlay.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}


final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'ClientPilot',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
      builder: (context, child) {
        // Initialize NotificationService once the app loads
        Future.microtask(() => ref.read(notificationServiceProvider).initialize());
        
        return CelebrationOverlay(
          celebrationStream: ref.watch(celebrationProvider).celebrationStream,
          child: StartupPermissionsGuard(child: child!),
        );
      },
    );
  }
}

