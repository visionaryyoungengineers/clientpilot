import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Initialize Firebase
      await Firebase.initializeApp();
      
      // 2. Initialize Isar Database
      await DatabaseService.instance;
      
      // 3. Navigate to App Router handling (Dashboard/Onboarding)
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      debugPrint('Initialization Error: $e');
      // Fallback navigation even on error to avoid permanent freeze
      if (mounted) {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using a simple gradient logo placeholder for the splash
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                gradient: AppColors.gradientHero,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))
                ],
              ),
              child: const Icon(Icons.rocket_launch, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Initializing Workspace...',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
