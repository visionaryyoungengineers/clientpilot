import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local auth state — no server dependency.
/// Authentication is considered always true (local-only app).
class UserAuth {
  final String? id;
  final String? email;
  final bool isAuthenticated;

  UserAuth({this.id, this.email, this.isAuthenticated = true});

  UserAuth copyWith({String? id, String? email, bool? isAuthenticated}) {
    return UserAuth(
      id: id ?? this.id,
      email: email ?? this.email,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<UserAuth> {
  AuthNotifier() : super(UserAuth()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('profile_name');
    state = state.copyWith(
      id: '1',
      email: name ?? 'User',
      isAuthenticated: true,
    );
  }

  Future<void> logout() async {
    state = UserAuth(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserAuth>((ref) {
  return AuthNotifier();
});
