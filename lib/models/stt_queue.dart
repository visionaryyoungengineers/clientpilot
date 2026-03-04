import 'package:isar/isar.dart';

part 'stt_queue.g.dart';

@collection
class SttQueue {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String conversationId;
  late String audioPath;
  
  @Index()
  late String status; // 'pending', 'processing', 'completed', 'failed'
  
  String? resultText;
  String? errorMessage;
  
  DateTime? createdAt;
  DateTime? updatedAt;
}
