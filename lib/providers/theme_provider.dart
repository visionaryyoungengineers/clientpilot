import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { light, dark, neuglass }

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.light);

  void setThemeMode(AppThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  return ThemeModeNotifier();
});
