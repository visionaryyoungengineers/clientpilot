import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'celebration_service.dart';

class StreakService extends StateNotifier<int> {
  final Ref ref;
  
  StreakService(this.ref) : super(0) {
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastActiveDay = prefs.getString('last_streak_day');
    int currentStreak = prefs.getInt('current_streak_count') ?? 0;

    if (lastActiveDay != null && lastActiveDay != today) {
      final lastDate = DateTime.parse(lastActiveDay);
      final diff = DateTime.now().difference(lastDate).inDays;
      if (diff > 1) {
        // Streak broken
        currentStreak = 0;
        await prefs.setInt('current_streak_count', 0);
      }
    }
    
    state = currentStreak;
  }

  Future<void> incrementAction() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastActiveDay = prefs.getString('last_streak_day');
    
    // Only increment the 'daily' streak once per day upon first meaningful action
    if (lastActiveDay != today) {
      int newStreak = (prefs.getInt('current_streak_count') ?? 0) + 1;
      await prefs.setInt('current_streak_count', newStreak);
      await prefs.setString('last_streak_day', today);
      
      state = newStreak;
      
      // Trigger Celebration for milestones
      if (newStreak == 3) {
        ref.read(celebrationProvider).celebrate('🔥 3 Day Streak! Keep it up!');
      } else if (newStreak == 7) {
        ref.read(celebrationProvider).celebrate('🎉 1 Week Streak! Amazing!');
      } else if (newStreak > 0 && newStreak % 10 == 0) {
        ref.read(celebrationProvider).celebrate('🏆 Huge Milestone: $newStreak Days!');
      } else {
        ref.read(celebrationProvider).celebrate('🔥 Daily Streak Extended!');
      }
    }
  }
}

final streakProvider = StateNotifierProvider<StreakService, int>((ref) {
  return StreakService(ref);
});
