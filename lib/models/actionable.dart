import 'package:isar/isar.dart';

part 'actionable.g.dart';

@collection
class Actionable {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String title;
  bool isCompleted = false;
  DateTime? dueDate;
  String? assignee;
  String? assignedBy;
  DateTime? assignedAt;
  String? conversationId;
  String? audioNoteUrl;

  /// JSON string containing custom field data
  String? customFieldsData;

  DateTime? createdAt;
  DateTime? updatedAt;
}
