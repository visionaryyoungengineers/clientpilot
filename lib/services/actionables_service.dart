import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/actionable.dart';
import 'database_service.dart';

class ActionablesNotifier extends StateNotifier<List<Actionable>> {
  ActionablesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final isar = await DatabaseService.instance;
    // idGreaterThan(-1) = all records; QAfterWhereClause has findAll()
    final all = await isar.actionables.where().idGreaterThan(-1).findAll();
    all.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    if (mounted) state = all;
  }

  Future<void> refresh() => _load();

  Future<void> addManual({
    required String title,
    String? notes,
    DateTime? dueDate,
    String? assignee,
    String? assignedBy,
    String? conversationId,
    String? customFieldsData,
  }) async {
    final isar = await DatabaseService.instance;
    final act = Actionable()
      ..uuid = const Uuid().v4()
      ..title = title
      ..assignee = assignee
      ..assignedBy = assignedBy ?? 'Me'
      ..assignedAt = DateTime.now()
      ..isCompleted = false
      ..conversationId = conversationId
      ..customFieldsData = customFieldsData
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    if (dueDate != null) act.dueDate = dueDate;

    await isar.writeTxn(() async => isar.actionables.put(act));
    await _load();
  }

  Future<void> toggleComplete(String uuid) async {
    final isar = await DatabaseService.instance;
    final all = await isar.actionables.where().idGreaterThan(-1).findAll();
    final existing = all.where((a) => a.uuid == uuid).firstOrNull;
    if (existing == null) return;
    existing.isCompleted = !existing.isCompleted;
    existing.updatedAt = DateTime.now();
    await isar.writeTxn(() async => isar.actionables.put(existing));
    await _load();
  }

  Future<void> delete(String uuid) async {
    final isar = await DatabaseService.instance;
    final all = await isar.actionables.where().idGreaterThan(-1).findAll();
    final existing = all.where((a) => a.uuid == uuid).firstOrNull;
    if (existing == null) return;
    await isar.writeTxn(() async => isar.actionables.delete(existing.id));
    await _load();
  }

  List<Actionable> forConversation(String conversationId) =>
      state.where((a) => a.conversationId == conversationId).toList();
}

final actionablesProvider =
    StateNotifierProvider<ActionablesNotifier, List<Actionable>>(
  (ref) => ActionablesNotifier(),
);
