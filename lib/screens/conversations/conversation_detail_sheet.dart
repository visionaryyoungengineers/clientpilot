import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../models/conversation.dart';
import '../../models/actionable.dart';
import '../../services/actionables_service.dart';
import 'conversations_screen.dart'; // for InterestLevel enum

import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/background_processing_service.dart';

class ConversationDetailSheet extends ConsumerStatefulWidget {
  final Conversation conversation;
  final String formatCurrency;
  
  const ConversationDetailSheet({
    super.key, 
    required this.conversation, 
    required this.formatCurrency
  });

  @override
  ConsumerState<ConversationDetailSheet> createState() => _ConversationDetailSheetState();
}

class _ConversationDetailSheetState extends ConsumerState<ConversationDetailSheet> {
  final TextEditingController _inputController = TextEditingController();
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;

  @override
  void dispose() {
    _inputController.dispose();
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
      _audioPath = '${dir.path}/chat_actionable_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1), path: _audioPath!);
      setState(() { _isRecording = true; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recording error: $e')));
    }
  }

  Future<void> _stopRecording() async {
    setState(() => _isRecording = false);
    try {
      final path = await _recorder.stop();
      if (path == null || path.isEmpty) return;
      
      ref.read(backgroundProcessingProvider.notifier).enqueueTask(
        'Voice Note Actionable',
        path,
        TaskType.chatInteraction,
        associatedId: widget.conversation.id.toString(),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice note queued for AI extraction.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _submitText() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    
    ref.read(backgroundProcessingProvider.notifier).enqueueTextTask(
      'Text Note Actionable',
      text,
      TaskType.chatInteraction,
      associatedId: widget.conversation.id.toString(),
    );
    
    _inputController.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Text note queued for AI extraction.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Map InterestLevel string to proper value
    final interestMap = {
      'hot': InterestLevel.hot,
      'warm': InterestLevel.warm,
      'cold': InterestLevel.cold
    };
    final intLevel = interestMap[widget.conversation.interestLevel] ?? InterestLevel.warm;

    final (IconData interestIcon, Color interestColor, String interestLabel) = switch (intLevel) {
      InterestLevel.hot  => (LucideIcons.flame,     const Color(0xFFef4444), 'Hot'),
      InterestLevel.warm => (LucideIcons.sun,        AppColors.amber, 'Warm'),
      InterestLevel.cold => (LucideIcons.snowflake,  const Color(0xFF60A5FA), 'Cold'),
    };
    
    final name = widget.conversation.contactName ?? 'Unknown';

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conversation Details',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                // Header (Name & Project)
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientHero,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(widget.conversation.contactCompany ?? '', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withAlpha(150))),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Key Stats Row
                Row(
                  children: [
                    Expanded(child: _DetailBox(label: 'Project', value: widget.conversation.projectName ?? 'No Project', icon: LucideIcons.briefcase)),
                    const SizedBox(width: 12),
                    Expanded(child: _DetailBox(label: 'Value', value: widget.formatCurrency, icon: LucideIcons.indianRupee)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Icon(interestIcon, size: 16, color: interestColor),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Interest', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(150))),
                                Text(interestLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: interestColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Icon(LucideIcons.star, size: 16, color: AppColors.amber),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rating', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(150))),
                                Text('${widget.conversation.importance ?? 0}/5', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Summary
                const Text('SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    widget.conversation.summary ?? 'No summary available.',
                    style: TextStyle(fontSize: 14, height: 1.5, color: theme.colorScheme.onSurface.withAlpha(200)),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Actionables & Participants
                Row(
                  children: [
                    Expanded(
                      child: Builder(builder: (ctx) {
                        final allActionables = ref.watch(actionablesProvider);
                        final convId = widget.conversation.id?.toString() ?? '';
                        final convActionables = convId.isEmpty
                            ? <Actionable>[]
                            : allActionables.where((a) => a.conversationId == convId && !a.isCompleted).toList();
                        return GestureDetector(
                          onTap: convActionables.isEmpty ? null : () => _showActionablesList(context, convActionables),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              children: [
                                Icon(LucideIcons.listTodo, color: convActionables.isNotEmpty ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(80)),
                                const SizedBox(height: 8),
                                const Text('Actionables', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  convActionables.isEmpty ? 'None' : '${convActionables.length} Pending',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: convActionables.isNotEmpty ? theme.colorScheme.primary : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Icon(LucideIcons.users, color: theme.colorScheme.primary),
                            const SizedBox(height: 8),
                            const Text('Participants', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('${widget.conversation.participants.length} People', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                if (widget.conversation.audioUrl != null) ...[
                  const Text('LATEST AUDIO NOTE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(20), shape: BoxShape.circle),
                          child: Icon(LucideIcons.play, size: 18, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(value: 0.3, backgroundColor: theme.colorScheme.onSurface.withAlpha(20), valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary)),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('0:00', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(150))),
                                  Text('Play Audio', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(150))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
              ],
            ),
          ),
          
          // Action Input Bar
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Add an actionable task...',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(LucideIcons.send, color: theme.colorScheme.primary, size: 20),
                          onPressed: _submitText,
                        ),
                      ),
                      onSubmitted: (_) => _submitText(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) => _stopRecording(),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hold to record voice memo')));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(_isRecording ? 16 : 12),
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isRecording ? LucideIcons.mic : LucideIcons.micOff,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}

class _DetailBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailBox({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: theme.colorScheme.onSurface.withAlpha(150)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(150))),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

void _showActionablesList(BuildContext context, List<Actionable> actionables) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Actionables', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...actionables.map((a) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.radio_button_unchecked, size: 20),
            title: Text(a.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: a.dueDate != null
                ? Text('Due: ${a.dueDate!.day}/${a.dueDate!.month}/${a.dueDate!.year}',
                    style: const TextStyle(fontSize: 12))
                : null,
            trailing: a.assignee != null
                ? Chip(label: Text(a.assignee!, style: const TextStyle(fontSize: 11)))
                : null,
          )),
        ],
      ),
    ),
  );
}
