import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/badge.dart';
import '../models/conversation.dart';
import '../models/contact.dart';
import '../models/actionable.dart';

/// Badge definition mirroring the Capacitor `badge-definitions.ts`
class BadgeDefinition {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final Future<bool> Function(Isar isar) evaluate;

  const BadgeDefinition({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.evaluate,
  });
}

final _badgeDefinitions = <BadgeDefinition>[
  BadgeDefinition(
    id: 'first-conversation',
    emoji: '🤝',
    title: 'First Contact',
    description: 'Log your first 3 client conversations',
    evaluate: (isar) async {
      final convs = await isar.conversations.where().anyId().findAll();
      return convs.length >= 3;
    },
  ),
  BadgeDefinition(
    id: 'five-conversations',
    emoji: '🧲',
    title: 'Client Magnet',
    description: 'Add 10 client conversations',
    evaluate: (isar) async {
      final convs = await isar.conversations.where().anyId().findAll();
      return convs.length >= 10;
    },
  ),
  BadgeDefinition(
    id: 'ten-conversations',
    emoji: '🌐',
    title: 'Networking Pro',
    description: 'Reach 25 client conversations',
    evaluate: (isar) async {
      final convs = await isar.conversations.where().anyId().findAll();
      return convs.length >= 25;
    },
  ),
  BadgeDefinition(
    id: 'followup-ninja',
    emoji: '🥷',
    title: 'Follow-up Ninja',
    description: 'Complete 25 actionable follow-ups',
    evaluate: (isar) async {
      final all = await isar.actionables.where().anyId().findAll();
      return all.where((a) => a.isCompleted).length >= 25;
    },
  ),
  BadgeDefinition(
    id: 'task-master',
    emoji: '✅',
    title: 'Task Master',
    description: 'Complete 15 standalone to-dos',
    evaluate: (isar) async {
      final all = await isar.actionables.where().anyId().findAll();
      return all.where((a) => a.isCompleted && a.conversationId == null).length >= 15;
    },
  ),
  BadgeDefinition(
    id: 'voice-master',
    emoji: '🎙️',
    title: 'Voice Master',
    description: 'Record 10 voice memos',
    evaluate: (isar) async {
      final all = await isar.actionables.where().anyId().findAll();
      return all.where((a) => a.audioNoteUrl != null).length >= 10;
    },
  ),
  BadgeDefinition(
    id: 'pipeline-10l',
    emoji: '💎',
    title: 'Pipeline Pro',
    description: 'Maintain ₹25L+ in pipeline value',
    evaluate: (isar) async {
      final convs = await isar.conversations.where().anyId().findAll();
      final total = convs.fold<double>(0, (sum, c) => sum + (c.dealAmount ?? 0));
      return total >= 2500000;
    },
  ),
  BadgeDefinition(
    id: 'deal-closer',
    emoji: '🎯',
    title: 'Deal Closer',
    description: 'Have 10 hot leads in your pipeline',
    evaluate: (isar) async {
      final convs = await isar.conversations.where().anyId().findAll();
      return convs.where((c) => c.interestLevel == 'hot').length >= 10;
    },
  ),
  BadgeDefinition(
    id: 'networker',
    emoji: '👥',
    title: 'Networker',
    description: 'Add 50 people to your directory',
    evaluate: (isar) async {
      final contacts = await isar.contacts.where().anyId().findAll();
      return contacts.length >= 50;
    },
  ),
  BadgeDefinition(
    id: 'pilot-elite',
    emoji: '👑',
    title: 'Pilot Elite',
    description: 'Earn 5 other badges',
    evaluate: (isar) async {
      final earned = await isar.badges.filter().badgeIdIsNotEmpty().findAll();
      return earned.where((b) => b.unlockedAt != null).length >= 5;
    },
  ),
];

class GamificationEngine {
  static final List<BadgeDefinition> definitions = _badgeDefinitions;

  /// Evaluates all badge rules against live Isar data and writes newly earned ones.
  /// Returns a list of newly unlocked badge titles (for celebration toasts).
  Future<List<String>> evaluateAndAward(Isar isar) async {
    final newlyUnlocked = <String>[];

    for (final def in definitions) {
      // Skip if already earned
      final existing = await isar.badges.filter().badgeIdIsNotEmpty().findAll();
      final alreadyEarned = existing.any((b) => b.badgeId == def.id && b.unlockedAt != null);
      if (alreadyEarned) continue;

      final earned = await def.evaluate(isar);
      if (!earned) continue;

      // Write the badge
      await isar.writeTxn(() async {
        final badge = Badge()
          ..uuid = const Uuid().v4()
          ..badgeId = def.id
          ..title = def.title
          ..description = def.description
          ..iconUrl = def.emoji
          ..unlockedAt = DateTime.now()
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();
        await isar.badges.put(badge);
      });

      newlyUnlocked.add('${def.emoji} ${def.title}');
    }

    return newlyUnlocked;
  }
}

final gamificationEngineProvider = Provider((ref) => GamificationEngine());
