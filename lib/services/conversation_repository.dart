import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';
import 'database_service.dart';

class ConversationRepository {
  final Isar _isar;
  ConversationRepository(this._isar);

  /// Stream of all conversations sorted newest-first.
  /// Automatically emits new lists whenever the DB changes.
  Stream<List<Conversation>> watchAll() =>
      _isar.conversations.where().sortByCreatedAtDesc().watch(fireImmediately: true);

  Future<List<Conversation>> getAll() =>
      _isar.conversations.where().sortByCreatedAtDesc().findAll();

  Future<void> save(Conversation conv) async {
    bool isNew = (conv.id == Isar.autoIncrement);
    conv.uuid = conv.uuid.isNotEmpty ? conv.uuid : const Uuid().v4();
    conv.createdAt ??= DateTime.now();
    conv.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.conversations.put(conv));

    // Gamification Logics
    if (isNew) {
      final prefs = await SharedPreferences.getInstance();
      
      // First Client
      if (!(prefs.getBool('badge_First Client') ?? false)) {
        await prefs.setBool('badge_First Client', true);
      }
      
      // Hot Streak (5 per day)
      final todayStr = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
      final lastHotStreakDay = prefs.getString('hot_streak_day');
      int hotStreakCount = 1;
      if (lastHotStreakDay == todayStr) {
        hotStreakCount = (prefs.getInt('hot_streak_count') ?? 0) + 1;
      }
      await prefs.setString('hot_streak_day', todayStr);
      await prefs.setInt('hot_streak_count', hotStreakCount);
      if (hotStreakCount >= 5) await prefs.setBool('badge_Hot Streak', true);
    }
    
    // Star Performer
    if (conv.importance == 5) {
      final prefs = await SharedPreferences.getInstance();
      int fiveStars = (prefs.getInt('five_star_count') ?? 0) + 1;
      await prefs.setInt('five_star_count', fiveStars);
      if (fiveStars >= 3) await prefs.setBool('badge_Star Performer', true);
    }
    
    // Deal Closer
    if (conv.dealStatus == 'Won') {
      final prefs = await SharedPreferences.getInstance();
      int wonDeals = (prefs.getInt('won_deals_count') ?? 0) + 1;
      await prefs.setInt('won_deals_count', wonDeals);
      if (wonDeals >= 5) await prefs.setBool('badge_Deal Closer', true);
    }
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.conversations.delete(id));
  }
}

// ------------------------------------------------------------------
// Providers
// ------------------------------------------------------------------

/// Provides the ConversationRepository once Isar is ready.
final conversationRepoProvider = FutureProvider<ConversationRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return ConversationRepository(isar);
});

/// A reactive stream of conversations — UI rebuilds automatically on any DB write.
final conversationsStreamProvider = StreamProvider<List<Conversation>>((ref) async* {
  final repo = await ref.watch(conversationRepoProvider.future);
  yield* repo.watchAll();
});
