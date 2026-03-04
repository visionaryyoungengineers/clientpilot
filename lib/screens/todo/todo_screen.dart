import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aero_card.dart';
import '../../services/background_processing_service.dart';
import '../../services/actionables_service.dart';
import '../../models/actionable.dart';
import '../../services/celebration_service.dart';
import '../../services/streak_service.dart';
import 'add_todo_sheet.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});
  @override ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final _audioPlayer = AudioPlayer();
  String? _playingTaskId;
  String? _profileName;

  @override
  void initState() {
    super.initState();
    _loadProfileName();
  }

  Future<void> _loadProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _profileName = prefs.getString('profile_name')?.toLowerCase().trim());
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(BackgroundTask task) async {
    if (_playingTaskId == task.id) {
      await _audioPlayer.stop();
      setState(() => _playingTaskId = null);
    } else {
      final file = File(task.filePath);
      if (!file.existsSync()) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audio file not found: ${task.filePath}')));
        return;
      }
      setState(() => _playingTaskId = task.id);
      await _audioPlayer.play(DeviceFileSource(task.filePath));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _playingTaskId = null);
      });
    }
  }

  /// Returns true if the actionable belongs to the current user.
  /// Includes tasks with no assignee (manually created) and tasks assigned to
  /// "me" or the user's profile name.
  bool _isMyTask(Actionable a) {
    final assignee = a.assignee?.toLowerCase().trim();
    if (assignee == null || assignee.isEmpty) return true; // manually created
    if (assignee == 'me') return true;
    if (_profileName != null && assignee == _profileName) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allActionables = ref.watch(actionablesProvider);
    // Only show MY tasks in the To-Do section
    final myActionables = allActionables.where(_isMyTask).toList();
    final pending = myActionables.where((a) => !a.isCompleted).toList();
    final done = myActionables.where((a) => a.isCompleted).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            // ── Header stat ─────────────────────────────────────────────
            AeroCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(children: [
                _StatBadge(count: pending.length, label: 'Pending', color: theme.colorScheme.primary),
                const SizedBox(width: 24),
                _StatBadge(count: done.length, label: 'Completed', color: const Color(0xFF16A34A)),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Background Queue Viewer ──────────────────────────────────
            Consumer(builder: (context, ref, child) {
              final tasks = ref.watch(backgroundProcessingProvider).where((t) => t.type == TaskType.todoNote).toList();
              if (tasks.isEmpty) return const SizedBox.shrink();
              return Column(children: [
                AeroCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(LucideIcons.sparkles, size: 14),
                        const SizedBox(width: 6),
                        Text('AI Processing (${tasks.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ]),
                      const SizedBox(height: 6),
                      ...tasks.map((task) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: task.status == TaskStatus.processing
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(task.status == TaskStatus.completed ? Icons.check_circle_outline : Icons.audio_file, size: 20),
                        title: Text(task.title, style: const TextStyle(fontSize: 13)),
                        subtitle: Text(
                          task.status == TaskStatus.completed ? 'Saved to Actionables ✓' : task.status.name,
                          style: TextStyle(fontSize: 11, color: task.status == TaskStatus.completed ? const Color(0xFF16A34A) : null),
                        ),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                            icon: Icon(_playingTaskId == task.id ? Icons.stop : Icons.play_arrow, size: 20),
                            onPressed: () => _togglePlay(task),
                          ),
                          IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () {
                            ref.read(backgroundProcessingProvider.notifier).removeTask(task.id);
                          }),
                        ]),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ]);
            }),

            // ── Pending ─────────────────────────────────────────────────
            if (pending.isNotEmpty) ...[
              Text('PENDING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: theme.colorScheme.onSurface.withAlpha(120))),
              const SizedBox(height: 10),
              ...pending.map((a) => _ActionableCard(
                actionable: a,
                onToggle: () async {
                  await ref.read(actionablesProvider.notifier).toggleComplete(a.uuid);
                  // Only celebrate when marking as completed (not un-completing)
                  if (!a.isCompleted && mounted) {
                    ref.read(celebrationProvider).celebrate('Nailed it!');
                    ref.read(streakProvider.notifier).incrementAction();
                  }
                },
                onDelete: () => ref.read(actionablesProvider.notifier).delete(a.uuid),
              )),
              const SizedBox(height: 20),
            ],

            // ── Completed ───────────────────────────────────────────────
            if (done.isNotEmpty) ...[
              Text('COMPLETED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: theme.colorScheme.onSurface.withAlpha(120))),
              const SizedBox(height: 10),
              ...done.map((a) => _ActionableCard(
                actionable: a,
                onToggle: () => ref.read(actionablesProvider.notifier).toggleComplete(a.uuid),
                onDelete: () => ref.read(actionablesProvider.notifier).delete(a.uuid),
              )),
            ],

            if (myActionables.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(children: [
                    Icon(LucideIcons.listTodo, size: 48, color: theme.colorScheme.onSurface.withAlpha(60)),
                    const SizedBox(height: 12),
                    Text('No tasks assigned to you yet', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(100), fontSize: 15)),
                    const SizedBox(height: 6),
                    Text('Tap + or use the mic to add one', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(70), fontSize: 13)),
                  ]),
                ),
              ),
          ],
        ),

        // FAB
        Positioned(
          bottom: 100, right: 20,
          child: GestureDetector(
            onTap: () => _openAddSheet(context),
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: theme.colorScheme.primary.withAlpha(80), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 26),
            ),
          ),
        ),
      ]),
    );
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: AddTodoSheet(onTodoAdded: () {
          ref.read(actionablesProvider.notifier).refresh();
        }),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final int count; final String label; final Color color;
  const _StatBadge({required this.count, required this.label, required this.color});
  @override Widget build(BuildContext context) => Row(children: [
    Text('$count', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
  ]);
}

class _ActionableCard extends ConsumerWidget {
  final Actionable actionable;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const _ActionableCard({required this.actionable, required this.onToggle, required this.onDelete});

  @override Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOverdue = actionable.dueDate != null && actionable.dueDate!.isBefore(DateTime.now()) && !actionable.isCompleted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AeroCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: actionable.isCompleted ? const Color(0xFF16A34A) : Colors.transparent,
                border: Border.all(color: actionable.isCompleted ? const Color(0xFF16A34A) : theme.colorScheme.onSurface.withAlpha(80), width: 2),
              ),
              child: actionable.isCompleted ? const Icon(LucideIcons.check, size: 14, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              actionable.title,
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600,
                decoration: actionable.isCompleted ? TextDecoration.lineThrough : null,
                color: actionable.isCompleted ? theme.colorScheme.onSurface.withAlpha(100) : theme.colorScheme.onSurface,
              ),
            ),
            if (actionable.dueDate != null || actionable.assignee != null || (actionable.assignedBy != null && actionable.assignedBy != 'Me')) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                if (actionable.dueDate != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOverdue ? theme.colorScheme.error.withAlpha(20) : theme.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isOverdue ? theme.colorScheme.error.withAlpha(50) : theme.colorScheme.primary.withAlpha(50)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.calendar, size: 12, color: isOverdue ? theme.colorScheme.error : theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${_formatDate(actionable.dueDate!)}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOverdue ? theme.colorScheme.error : theme.colorScheme.primary),
                      ),
                    ]),
                  ),
                ],
                if (actionable.assignee != null) ...[
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.user, size: 12, color: theme.colorScheme.onSurface.withAlpha(120)),
                    const SizedBox(width: 4),
                    Text(actionable.assignee!, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(120))),
                  ]),
                ],
              ]),
            ],
            // Assigned By metadata
            if (actionable.assignedBy != null && actionable.assignedBy != 'Me') ...[
              const SizedBox(height: 6),
              Text(
                'Assigned by ${actionable.assignedBy} ${actionable.assignedAt != null ? 'on ${_formatDate(actionable.assignedAt!)}' : ''}',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withAlpha(100)),
              ),
            ],
          ])),
          GestureDetector(
            onTap: onDelete,
            child: Icon(LucideIcons.trash2, size: 16, color: theme.colorScheme.onSurface.withAlpha(80)),
          ),
        ]),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) return 'Today';
    final tomorrow = now.add(const Duration(days: 1));
    if (d.year == tomorrow.year && d.month == tomorrow.month && d.day == tomorrow.day) return 'Tomorrow';
    return '${months[d.month]} ${d.day}';
  }
}
