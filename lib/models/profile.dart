import 'package:isar/isar.dart';

part 'profile.g.dart';

@collection
class Profile {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  String? name;
  String? email;
  String? company;
  String? phone;
  String? avatarUrl;
  String? businessType;
  int? loginStreak;
  int? totalXp;
  bool? onboarded;
  DateTime? createdAt;
  DateTime? updatedAt;
}
