import 'package:isar/isar.dart';

part 'conversation.g.dart';

@collection
class Conversation {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  String? personId;
  String? contactName;
  String? contactPhone;
  String? contactCompany;
  String? projectName;
  String? businessSize;

  String? summary;
  String? remarks;
  String? interestLevel;
  String? contactType;
  String? dealStatus;
  double? dealAmount; // Added for pipeline tracking
  int? importance;
  DateTime? revertBy;

  List<String> participants = [];
  List<String> attachments = [];

  String? audioUrl;
  
  // New JSON string for dynamically defined custom fields scoped to Chat
  String? customFieldsData;

  DateTime? createdAt;
  DateTime? updatedAt;
}
