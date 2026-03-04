import 'package:isar/isar.dart';

part 'contact.g.dart';

@collection
class Contact {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String name;
  String? phone;
  String? email;
  String? company;
  String? photoUrl;
  List<String> roles = [];
  String? bio;
  String? gender;
  List<String> tags = [];
  List<String> audioNotes = [];
  String? website;
  String? address;

  DateTime? dateOfBirth;
  DateTime? anniversary;

  /// JSON string containing custom field data (e.g. {"Lead Source": "Referral"})
  String? customFieldsData;

  DateTime? createdAt;
  DateTime? updatedAt;
}
