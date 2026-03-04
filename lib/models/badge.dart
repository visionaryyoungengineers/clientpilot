import 'package:isar/isar.dart';

part 'badge.g.dart';

@collection
class Badge {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String badgeId;
  late String title;
  late String description;
  String? iconUrl;
  DateTime? unlockedAt;
  
  DateTime? createdAt;
  DateTime? updatedAt;
}
