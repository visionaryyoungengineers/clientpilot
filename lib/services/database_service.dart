import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation.dart';
import '../models/contact.dart';
import '../models/actionable.dart';
import '../models/badge.dart';
import '../models/profile.dart';
import '../models/stt_queue.dart';
import '../models/team_member.dart';
import '../models/custom_field_def.dart';

class DatabaseService {
  static Isar? _instance;

  static Future<Isar> get instance async {
    if (_instance != null && _instance!.isOpen) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [
        ConversationSchema,
        ContactSchema,
        ActionableSchema,
        BadgeSchema,
        ProfileSchema,
        SttQueueSchema,
        TeamMemberSchema,
        CustomFieldDefSchema,
      ],
      directory: dir.path,
    );
    return _instance!;
  }
}

final isarProvider = FutureProvider<Isar>((ref) => DatabaseService.instance);
