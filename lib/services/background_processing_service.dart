import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';
import 'dart:convert';
import 'dart:io';
import 'model_manager_service.dart';
import 'package:path_provider/path_provider.dart';
import 'local_llm_service.dart';
import 'package:whisper_kit/whisper_kit.dart';
import 'database_service.dart';
import '../models/actionable.dart';
import '../models/conversation.dart';
import '../models/contact.dart';
import 'conversation_repository.dart';

enum TaskType { businessContext, contactContext, chatInteraction, todoNote }
enum TaskStatus { pending, processing, completed, error }

class BackgroundTask {
  final String id;
  final String title;
  final String filePath; // or pure Text if type is text
  final TaskType type;
  TaskStatus status;
  String? resultData;
  String? associatedId;

  BackgroundTask({
    required this.id,
    required this.title,
    required this.filePath,
    required this.type,
    this.status = TaskStatus.pending,
    this.resultData,
    this.associatedId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'filePath': filePath,
    'type': type.toString(),
    'status': status.toString(),
    'resultData': resultData,
    'associatedId': associatedId,
  };

  factory BackgroundTask.fromJson(Map<String, dynamic> json) => BackgroundTask(
    id: json['id'],
    title: json['title'],
    filePath: json['filePath'],
    type: TaskType.values.firstWhere((e) => e.toString() == json['type']),
    status: TaskStatus.values.firstWhere((e) => e.toString() == json['status']),
    resultData: json['resultData'],
    associatedId: json['associatedId'],
  );
}

class BackgroundProcessingService extends StateNotifier<List<BackgroundTask>> {
  final Ref ref;
  BackgroundProcessingService(this.ref) : super([]) {
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final String? queueStr = prefs.getString('background_task_queue');
    if (queueStr != null) {
      final List<dynamic> decoded = jsonDecode(queueStr);
      state = decoded.map((e) => BackgroundTask.fromJson(e)).toList();
      
      // Reset any stuck "processing" tasks back to "pending"
      bool needProcess = false;
      state = state.map((t) {
        if (t.status == TaskStatus.processing || t.status == TaskStatus.pending) {
          t.status = TaskStatus.pending;
          needProcess = true;
        }
        return t;
      }).toList();
      
      if (needProcess) _processNext();
    }
  }

  Future<void> _saveQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString('background_task_queue', encoded);
  }

  final _uuid = const Uuid();

  void enqueueTask(String title, String filePath, TaskType type, {String? associatedId}) {
    final task = BackgroundTask(
      id: _uuid.v4(),
      title: title,
      filePath: filePath,
      type: type,
      associatedId: associatedId,
    );
    state = [...state, task];
    _saveQueue();
    _processNext();
  }

  void enqueueTextTask(String title, String text, TaskType type, {String? associatedId}) {
    final task = BackgroundTask(
      id: _uuid.v4(),
      title: title,
      filePath: text, // repurposing filePath constraint to hold direct text for STT bypass
      type: type,
      associatedId: associatedId,
    );
    state = [...state, task];
    _saveQueue();
    _processNext();
  }

  void removeTask(String id) {
    state = state.where((t) => t.id != id).toList();
    _saveQueue();
  }

  /// Clears all completed and error tasks from the queue.
  void clearErrors() {
    state = state.where((t) => t.status == TaskStatus.pending || t.status == TaskStatus.processing).toList();
    _saveQueue();
  }

  Future<void> _processNext() async {
    final pending = state.where((t) => t.status == TaskStatus.pending).toList();
    if (pending.isEmpty) return;
    
    // In a real scenario, this runs STT -> LLM. 
    // Here we will scaffold the actual calls soon.
    final current = pending.first;
    _updateStatus(current.id, TaskStatus.processing);

    try {
      final modelManager = ref.read(modelManagerProvider);
      
      String transcript = '';
      
      // If it's pure text payload, we can skip Whisper
      if (!current.filePath.endsWith('.wav') && !current.filePath.endsWith('.m4a')) {
        transcript = current.filePath;
      } else {
        // 1. STT Phase (Whisper)
        bool whisperDownloaded = await modelManager.isWhisperModelDownloaded();
        if (!whisperDownloaded) {
          _updateStatus(current.id, TaskStatus.processing, resultData: 'Downloading Whisper AI...');
          await modelManager.downloadWhisperModel(
            onProgress: (p) => _updateStatus(current.id, TaskStatus.processing, resultData: 'Downloading Whisper: ${(p * 100).toStringAsFixed(1)}%'),
            onSuccess: () {},
            onError: (e) => throw Exception('Whisper Download Failed: $e'),
          );
        }
        
        _updateStatus(current.id, TaskStatus.processing, resultData: 'Transcribing Audio...');
        final whisperPath = await modelManager.getWhisperModelPath();
        final modelDir = (await getApplicationDocumentsDirectory()).path;
        
        // Initialize and Transcribe
        final whisper = Whisper(model: WhisperModel.tiny, modelDir: modelDir);
        final sttResult = await whisper.transcribe(transcribeRequest: TranscribeRequest(audio: current.filePath));
        transcript = sttResult.text ?? '';
        
        if (transcript.isEmpty) {
           throw Exception('Audio transcribed to empty text. Check language or mic level.');
        }
      }
      
      // 2. LLM Phase:
      final llmService = ref.read(llmServiceProvider);

      bool downloaded = await modelManager.isModelDownloaded();
      if (!downloaded) {
        _updateStatus(current.id, TaskStatus.processing, resultData: 'Downloading Qwen 2.5...');
        // Wait for download
        await modelManager.downloadModel(
          onProgress: (p) => _updateStatus(current.id, TaskStatus.processing, resultData: 'Downloading Qwen 2.5: ${(p * 100).toStringAsFixed(1)}%'),
          onSuccess: () {},
          onError: (e) => throw Exception('Model Download Failed: $e'),
        );
      }
      
      _updateStatus(current.id, TaskStatus.processing, resultData: 'Analyzing with Qwen.5b...');
      final modelPath = await modelManager.getModelPath();

      // ── Special Case: Business Context / Contact Context bypassing LLM entirely ──────────
      if (current.type == TaskType.businessContext || current.type == TaskType.contactContext) {
        if (transcript.isNotEmpty) {
          if (current.type == TaskType.businessContext) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('profile_business_context', transcript);
          } else {
            // It's contactContext, update Isar
            if (current.associatedId != null) {
              final isar = await ref.read(isarProvider.future);
              final contact = await isar.contacts.filter().uuidEqualTo(current.associatedId!).findFirst();
              if (contact != null) {
                await isar.writeTxn(() async {
                  contact.bio = (contact.bio?.isNotEmpty ?? false) ? '${contact.bio}\n\n$transcript' : transcript;
                  contact.updatedAt = DateTime.now();
                  await isar.contacts.put(contact);
                });
              }
            }
          }
          _updateStatus(current.id, TaskStatus.completed, resultData: 'Context saved');
        } else {
          _updateStatus(current.id, TaskStatus.completed, resultData: 'Audio processed — empty transcript.');
        }
        await Future.delayed(const Duration(milliseconds: 500));
        _processNext();
        return;
      }

      // Try loading the native LLM — if libmtmd.so is missing, fallback to saving raw transcript
      bool llmAvailable = true;
      try {
        await llmService.loadModel(modelPath);
      } catch (llmInitError) {
        llmAvailable = false;
      }

      // ── LLM Fallback: if LLM not available, fail gracefully as AI is compulsory now ──────
      if (!llmAvailable) {
        _updateStatus(current.id, TaskStatus.error, resultData: 'LLM not available. AI is compulsory for processing actionables.');
        _processNext();
        return;
      }
      
      final jsonResultStr = await llmService.extractJsonFromTranscript(transcript, taskType: current.type.toString().split('.').last);
      
      // Parse JSON and save to database
      try {
        // Strip markdown if Qwen returned codeblocks
        String cleanJson = jsonResultStr;
        if (cleanJson.contains('```json')) {
          cleanJson = cleanJson.split('```json')[1].split('```')[0].trim();
        } else if (cleanJson.contains('```')) {
          cleanJson = cleanJson.split('```')[1].split('```')[0].trim();
        }
        
        final Map<String, dynamic> parsed = jsonDecode(cleanJson);
        final actionablesList = parsed['actionables'] as List<dynamic>? ?? [];
        
        final isar = await ref.read(isarProvider.future);

        // Pre-fetch the conversation BEFORE any write transaction (reads can't be inside writeTxn)
        Conversation? convToUpdate;
        if (current.type == TaskType.chatInteraction && current.associatedId != null) {
          final repo = ConversationRepository(isar);
          final allConvs = await repo.getAll();
          convToUpdate = allConvs.where((c) => c.uuid == current.associatedId).firstOrNull;
        }
          
        await isar.writeTxn(() async {
          // 1. If this is a Conversation, update its fields
          if (convToUpdate != null) {
            convToUpdate.contactName = parsed['contactName'] ?? convToUpdate.contactName;
            convToUpdate.contactPhone = parsed['contactPhone'] ?? convToUpdate.contactPhone;
            // The prompt returns "company", mapping to contactCompany
            convToUpdate.contactCompany = parsed['company'] ?? convToUpdate.contactCompany;
            convToUpdate.projectName = parsed['projectName'] ?? convToUpdate.projectName;
            convToUpdate.dealStatus = parsed['dealStatus'] ?? convToUpdate.dealStatus;
            
            if (parsed['dealAmount'] != null) {
              try {
                convToUpdate.dealAmount = double.parse(parsed['dealAmount'].toString());
              } catch (_) {}
            }
            convToUpdate.businessSize = parsed['businessSize']?.toString() ?? convToUpdate.businessSize;
            
            convToUpdate.interestLevel = parsed['interestLevel'] ?? convToUpdate.interestLevel;
            convToUpdate.contactType = parsed['contactType'] ?? convToUpdate.contactType;
            convToUpdate.remarks = parsed['remarks'] ?? convToUpdate.remarks;
            
            if (parsed['revertBy'] != null) {
              try {
                convToUpdate.revertBy = DateTime.parse(parsed['revertBy'].toString());
              } catch (_) {}
            }
            
            // If LLM returned a summary, use it. Otherwise, save transcript so something shows
            convToUpdate.summary = parsed['summary'] ?? (transcript.length > 200 ? '${transcript.substring(0, 200)}...' : transcript);
            convToUpdate.updatedAt = DateTime.now();
            await isar.conversations.put(convToUpdate);
          }

          // 2. Save extracted actionables
          for (var item in actionablesList) {
             final act = Actionable()
               ..uuid = const Uuid().v4()
               ..conversationId = current.associatedId // Bind to specific conversation if present
               ..title = item['title'] ?? 'Extracted Task'
               ..assignee = item['assignedTo']?.toString()
               ..isCompleted = false
               ..createdAt = DateTime.now()
               ..updatedAt = DateTime.now();
             
             if (item['dueDate'] != null) {
               // Try to parse ISO8601, else ignore
               try {
                 act.dueDate = DateTime.parse(item['dueDate']);
               } catch (_) {}
             }
             
             await isar.actionables.put(act);
          }
        });
      } catch (parseError) {
        print('[JSON Parse Error] $parseError');
      }

      // Update result based on Type
      _updateStatus(current.id, TaskStatus.completed, resultData: jsonResultStr);
      
      // trigger next
      _processNext();
    } catch (e) {
      _updateStatus(current.id, TaskStatus.error, resultData: e.toString());
    }
  }

  void _updateStatus(String id, TaskStatus newStatus, {String? resultData}) {
    state = state.map((t) {
      if (t.id == id) {
        t.status = newStatus;
        if (resultData != null) t.resultData = resultData;
      }
      return t;
    }).toList();
    
    // Auto-remove completed or errored tasks after short delay (per user request)
    if (newStatus == TaskStatus.completed || newStatus == TaskStatus.error) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) removeTask(id);
      });
    }
  }

}

final backgroundProcessingProvider = StateNotifierProvider<BackgroundProcessingService, List<BackgroundTask>>((ref) {
  return BackgroundProcessingService(ref);
});
