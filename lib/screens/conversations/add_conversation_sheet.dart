import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/aero_cta.dart';
import '../../theme/app_colors.dart';
import '../../services/background_processing_service.dart';
import '../../services/conversation_repository.dart';
import '../../models/conversation.dart';
import '../../services/streak_service.dart';
import '../../services/custom_field_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class AddConversationSheet extends ConsumerStatefulWidget {
  final VoidCallback? onConversationAdded;
  const AddConversationSheet({super.key, this.onConversationAdded});

  @override
  ConsumerState<AddConversationSheet> createState() => _AddConversationSheetState();
}

class _AddConversationSheetState extends ConsumerState<AddConversationSheet> {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  final Map<String, dynamic> _customValues = {}; // Custom Fields feature

  String _contactType = 'Client';
  String _dealStatus = 'Active';

  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _transcriptController = TextEditingController();
  bool _isListening = false;
  bool _isLoading = false;
  final _recorder = AudioRecorder();
  String? _audioPath;
  final List<XFile> _attachedFiles = [];
  final ImagePicker _imgPicker = ImagePicker();

  @override
  void dispose() {
    _summaryController.dispose();
    _transcriptController.dispose();
    _contactController.dispose();
    _companyController.dispose();
    _projectController.dispose();
    _amountController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission denied.')));
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      _audioPath = '${dir.path}/chat_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1), path: _audioPath!);
      setState(() { _isListening = true; _transcriptController.text = 'Recording...'; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recording error: $e')));
    }
  }

  Future<void> _stopAndQueueAI() async {
    setState(() { _isListening = false; _isLoading = true; });
    try {
      final path = await _recorder.stop();
      if (path == null || path.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No audio recorded.')));
        return;
      }
      ref.read(backgroundProcessingProvider.notifier).enqueueTask(
        'New Conversation from Audio',
        path,
        TaskType.chatInteraction,
      );
      ref.read(streakProvider.notifier).incrementAction();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio queued for AI processing.')));
      if (mounted) Navigator.of(context).pop();
      widget.onConversationAdded?.call();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConversation() async {
    // Silent validation per PRD: fail cleanly and quietly if empty
    if (_contactController.text.trim().isEmpty || _projectController.text.trim().isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final repo = await ref.read(conversationRepoProvider.future);
      final conv = Conversation()
        ..uuid = const Uuid().v4()
        ..contactName = _contactController.text.trim()
        ..contactCompany = _companyController.text.trim()
        ..projectName = _projectController.text.trim()
        ..businessSize = _amountController.text.trim()
        ..summary = _summaryController.text.trim()
        ..contactType = _contactType
        ..dealStatus = _dealStatus
        ..dealAmount = double.tryParse(_amountController.text.replaceAll(',', '').replaceAll('₹', '').trim())
        ..interestLevel = 'warm'
        ..updatedAt = DateTime.now();
        
      if (_customValues.isNotEmpty) {
        conv.customFieldsData = jsonEncode(_customValues);
      }
        
      await repo.save(conv);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    } finally {
      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onConversationAdded?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customFields = ref.watch(sectionCustomFieldsProvider('Chat'));
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Interaction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(LucideIcons.x, color: theme.colorScheme.onSurface.withAlpha(150)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16),
              children: [
                // AI Auto-Fill Hero Button
                GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) => _stopAndQueueAI(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: _isListening ? AppColors.gradientHero : null,
                      color: _isListening ? null : theme.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isListening ? Colors.transparent : theme.colorScheme.primary.withAlpha(40),
                      ),
                      boxShadow: _isListening ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(80),
                          blurRadius: 24,
                          spreadRadius: 2,
                        )
                      ] : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.bot, 
                          color: _isListening ? Colors.white : theme.colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isListening ? 'Recording... release to queue' : 'Hold & Speak to Queue Audio',
                          style: TextStyle(
                            color: _isListening ? Colors.white : theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (_transcriptController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _transcriptController.text,
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(180), fontStyle: FontStyle.italic),
                    ),
                  )
                ],

                const SizedBox(height: 24),
                const Text('CONTACT INFO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: 'Contact Name *',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _companyController,
                        decoration: InputDecoration(
                          labelText: 'Company',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _contactType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: ['Client', 'Vendor', 'Partner', 'Investor', 'Other']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                        onChanged: (v) => setState(() => _contactType = v!),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text('DEAL DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _projectController,
                  decoration: InputDecoration(
                    labelText: 'Project / Deal Name *',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _dealStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: ['Active', 'Won', 'Lost', 'Archived']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                        onChanged: (v) => setState(() => _dealStatus = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Deal Amount (₹)',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text('SUMMARY & ACTIONABLES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _summaryController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Conversation Summary',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                
                if (customFields.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text('CUSTOM FIELDS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                  const SizedBox(height: 12),
                  ...customFields.map((f) {
                    if (f.type == 'Dropdown') {
                      final opts = f.dropdownOptions?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? ['Option 1', 'Option 2'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: f.name, prefixIcon: const Icon(LucideIcons.listEnd, size: 18),
                            filled: true, fillColor: theme.colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                            filled: true, fillColor: theme.colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          onChanged: (v) => _customValues[f.name] = v,
                        ),
                      );
                    }
                  }),
                ],

                const SizedBox(height: 16),
                // Attach Files / Images ─────────────────────────────────
                GestureDetector(
                  onTap: () async {
                    final theme = Theme.of(context);
                    await showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      ListTile(leading: const Icon(LucideIcons.image), title: const Text('Gallery'), onTap: () async {
                        Navigator.pop(context);
                        final files = await _imgPicker.pickMultipleMedia();
                        if (files.isNotEmpty) setState(() => _attachedFiles.addAll(files));
                      }),
                      ListTile(leading: const Icon(LucideIcons.camera), title: const Text('Camera'), onTap: () async {
                        Navigator.pop(context);
                        final file = await _imgPicker.pickImage(source: ImageSource.camera);
                        if (file != null) setState(() => _attachedFiles.add(file));
                      }),
                    ])));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(LucideIcons.paperclip, size: 18, color: theme.colorScheme.onSurface.withAlpha(150)),
                      const SizedBox(width: 12),
                      Text('Attach Files or Images', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withAlpha(200))),
                      const Spacer(),
                      if (_attachedFiles.isNotEmpty)
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(10)),
                          child: Text('${_attachedFiles.length}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    ]),
                  ),
                ),
                if (_attachedFiles.isNotEmpty) ...[const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 4, children: _attachedFiles.asMap().entries.map((e) =>
                    Chip(
                      avatar: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.file(File(e.value.path), width: 24, height: 24, fit: BoxFit.cover)),
                      label: Text(e.value.name.length > 20 ? '${e.value.name.substring(0, 17)}...' : e.value.name, style: const TextStyle(fontSize: 11)),
                      onDeleted: () => setState(() => _attachedFiles.removeAt(e.key)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ).toList())
                ],

                const SizedBox(height: 70), // padding for CTA
              ],
            ),
          ),
          
          SizedBox(
            width: double.infinity,
            child: AeroCTA(
              label: 'Save Interaction',
              isLoading: _isLoading,
              onPressed: _saveConversation,
            ),
          ),
        ],
      ),
    );
  }
}

