import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../widgets/aero_cta.dart';
import '../../theme/app_colors.dart';
import '../../services/audio_recording_service.dart';
import '../../services/background_processing_service.dart';
import '../../services/actionables_service.dart';
import '../../services/custom_field_service.dart';
import 'dart:convert';

class AddTodoSheet extends ConsumerStatefulWidget {
  final VoidCallback? onTodoAdded;
  const AddTodoSheet({super.key, this.onTodoAdded});

  @override
  ConsumerState<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends ConsumerState<AddTodoSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _assignedByController = TextEditingController(); // Assigned By feature
  final Map<String, dynamic> _customValues = {}; // Custom Fields feature
  DateTime? _dueDate;
  bool _isLoading = false;
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _assignedByController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final audioService = ref.read(audioRecordingServiceProvider);
    try {
      if (await audioService.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/voicenote_${const Uuid().v4()}.wav';
        await audioService.startRecording(path);
        setState(() {
          _isRecording = true;
          _recordedFilePath = path;
        });
      }
    } catch (e) {
      print('[Audio] Error starting record: \$e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    final audioService = ref.read(audioRecordingServiceProvider);
    try {
      final path = await audioService.stopRecording();
      setState(() {
        _isRecording = false;
        if (path != null) {
          _recordedFilePath = path;
        }
      });
      
      if (path != null) {
        // Enqueue to background process immediately like chats
        ref.read(backgroundProcessingProvider.notifier).enqueueTask(
          'New Actionable from Audio',
          path,
          TaskType.todoNote
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio queued for background parsing.')));
        if (mounted) Navigator.of(context).pop();
        widget.onTodoAdded?.call();
      }
    } catch (e) {
      print('[Audio] Error stopping record: $e');
      setState(() => _isRecording = false);
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _saveTodo() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    
    await ref.read(actionablesProvider.notifier).addManual(
      title: _titleController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      dueDate: _dueDate,
      assignedBy: _assignedByController.text.trim().isEmpty ? null : _assignedByController.text.trim(),
      customFieldsData: _customValues.isNotEmpty ? jsonEncode(_customValues) : null,
    );
    
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.of(context).pop();
      widget.onTodoAdded?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final customFields = ref.watch(sectionCustomFieldsProvider('To-Do'));
    
    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'New Actionable',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(LucideIcons.x, color: AppColors.mutedForeground),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Task Title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Notes (Optional)',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _assignedByController,
          decoration: InputDecoration(
            labelText: 'Assigned By (Optional)',
            hintText: 'e.g. My boss, John Doe (defaults to "Me")',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        // Due date picker
        GestureDetector(
          onTap: _pickDueDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _dueDate != null ? AppColors.primary.withAlpha(15) : AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _dueDate != null ? AppColors.primary.withAlpha(80) : AppColors.border),
            ),
            child: Row(children: [
              Icon(LucideIcons.calendar, size: 18, color: _dueDate != null ? AppColors.primary : AppColors.mutedForeground),
              const SizedBox(width: 10),
              Text(
                _dueDate != null
                    ? 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                    : 'Set Due Date (Optional)',
                style: TextStyle(
                  color: _dueDate != null ? AppColors.primary : AppColors.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_dueDate != null) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _dueDate = null),
                  child: Icon(LucideIcons.x, size: 16, color: AppColors.mutedForeground),
                ),
              ],
            ]),
          ),
        ),
        
        if (customFields.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('Custom Fields', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...customFields.map((f) {
            if (f.type == 'Dropdown') {
              final opts = f.dropdownOptions?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? ['Option 1', 'Option 2'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: f.name, prefixIcon: const Icon(LucideIcons.listEnd, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  value: _customValues[f.name],
                  items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                  onChanged: (v) => setState(() => _customValues[f.name] = v),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  initialValue: _customValues[f.name]?.toString() ?? '',
                  keyboardType: f.type == 'Number' ? TextInputType.number : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: f.name, prefixIcon: Icon(f.type == 'Number' ? LucideIcons.hash : LucideIcons.text, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (v) => _customValues[f.name] = v,
                ),
              );
            }
          }),
        ],

        const SizedBox(height: 24),
        const Text('Voice Memo', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        
        GestureDetector(
          onLongPressStart: (_) => _startRecording(),
          onLongPressEnd: (_) => _stopRecording(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: _isRecording ? AppColors.destructive.withAlpha(20) : AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isRecording ? AppColors.destructive : AppColors.border,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  LucideIcons.mic, 
                  color: _isRecording ? AppColors.destructive : AppColors.primary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  _isRecording ? 'Recording! Release to stop' : 'Hold to Record Voice Note',
                  style: TextStyle(
                    color: _isRecording ? AppColors.destructive : AppColors.foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        
        // Removed manual audio selection/deleting file area since it auto-queues
        
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: AeroCTA(
            label: 'Save Task',
            isLoading: _isLoading,
            onPressed: _saveTodo,
          ),
        ),
      ],
      ),
    );
  }
}
