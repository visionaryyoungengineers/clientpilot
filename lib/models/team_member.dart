import 'package:isar/isar.dart';

part 'team_member.g.dart';

@collection
class TeamMember {
  Id id = Isar.autoIncrement;

  late String name;
  late String email;
  late String role; // 'Owner', 'Member'
  late String status; // 'active', 'invited'

  late DateTime createdAt;
  late DateTime updatedAt;
}
