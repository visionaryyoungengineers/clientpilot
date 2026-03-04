import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/custom_field_def.dart';
import 'database_service.dart';

class CustomFieldsNotifier extends StateNotifier<List<CustomFieldDef>> {
  CustomFieldsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final isar = await DatabaseService.instance;
    final all = await isar.customFieldDefs.where().idGreaterThan(-1).findAll();
    if (mounted) state = all;
  }

  Future<void> addField({
    required String name,
    required String type,
    required String section,
    String? dropdownOptions,
  }) async {
    final isar = await DatabaseService.instance;
    final field = CustomFieldDef()
      ..uuid = const Uuid().v4()
      ..name = name
      ..type = type
      ..section = section
      ..dropdownOptions = dropdownOptions
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.customFieldDefs.put(field);
    });
    
    await _load();
  }

  Future<void> deleteField(String uuid) async {
    final isar = await DatabaseService.instance;
    final all = await isar.customFieldDefs.where().idGreaterThan(-1).findAll();
    final existing = all.where((f) => f.uuid == uuid).firstOrNull;
    if (existing != null) {
      await isar.writeTxn(() async {
        await isar.customFieldDefs.delete(existing.id);
      });
      await _load();
    }
  }
}

final customFieldsProvider = StateNotifierProvider<CustomFieldsNotifier, List<CustomFieldDef>>((ref) {
  return CustomFieldsNotifier();
});

/// Helper to get fields specifically for a given section ('People', 'To-Do', 'Chat')
final sectionCustomFieldsProvider = Provider.family<List<CustomFieldDef>, String>((ref, section) {
  final fields = ref.watch(customFieldsProvider);
  return fields.where((f) => f.section == section).toList();
});
