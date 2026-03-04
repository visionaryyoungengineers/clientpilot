import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import 'database_service.dart';

class ContactsNotifier extends StateNotifier<List<Contact>> {
  ContactsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final isar = await DatabaseService.instance;
    final all = await isar.contacts.where().idGreaterThan(-1).findAll();
    // Sort alphabetically by name
    all.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (mounted) state = all;
  }

  Future<void> refresh() => _load();

  /// Pass an existing contact uuid. If it matches, update. Otherwise (or if null), add a new one.
  Future<void> saveContact({
    String? uuid,
    required String name,
    String? phone,
    String? email,
    String? company,
    String? bio,
    String? gender,
    String? website,
    String? address,
    DateTime? dateOfBirth,
    DateTime? anniversary,
    List<String> roles = const [],
    List<String> tags = const [],
  }) async {
    final isar = await DatabaseService.instance;

    Contact contactToSave;

    if (uuid != null) {
      final existingAll = await isar.contacts.where().idGreaterThan(-1).findAll();
      final existing = existingAll.where((c) => c.uuid == uuid).firstOrNull;
      
      if (existing != null) {
        contactToSave = existing;
      } else {
        contactToSave = Contact()
          ..uuid = uuid
          ..createdAt = DateTime.now();
      }
    } else {
      contactToSave = Contact()
        ..uuid = const Uuid().v4()
        ..createdAt = DateTime.now();
    }

    contactToSave
      ..name = name
      ..phone = phone
      ..email = email
      ..company = company
      ..bio = bio
      ..gender = gender
      ..website = website
      ..address = address
      ..dateOfBirth = dateOfBirth
      ..anniversary = anniversary
      ..roles = roles
      ..tags = tags
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.contacts.put(contactToSave);
    });

    await _load();
  }

  Future<void> deleteContact(String uuid) async {
    final isar = await DatabaseService.instance;
    final all = await isar.contacts.where().idGreaterThan(-1).findAll();
    final existing = all.where((c) => c.uuid == uuid).firstOrNull;
    if (existing == null) return;
    
    await isar.writeTxn(() async {
      await isar.contacts.delete(existing.id);
    });

    await _load();
  }
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, List<Contact>>((ref) {
  return ContactsNotifier();
});
