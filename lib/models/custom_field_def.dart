import 'package:isar/isar.dart';

part 'custom_field_def.g.dart';

@collection
class CustomFieldDef {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String name;
  
  /// e.g. "Text", "Number", "Date", "Dropdown"
  late String type;
  
  /// Options: "People", "To-Do", "Chat"
  late String section;

  /// Optional comma-separated list of options for Dropdown types
  String? dropdownOptions;

  DateTime? createdAt;
  DateTime? updatedAt;
}
