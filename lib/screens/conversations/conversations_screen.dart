import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import '../../theme/app_colors.dart';
import '../../widgets/aero_card.dart';
import '../../services/background_processing_service.dart';
import 'add_conversation_sheet.dart';
import 'conversation_detail_sheet.dart';

import '../../models/conversation.dart';
import '../../services/conversation_repository.dart';

// ─── Data models ─────────────────────────────────────────────────────────────
enum InterestLevel { hot, warm, cold }
enum ContactType { client, vendor, partner, investor, other }
enum DealStatus { active, won, lost, archived }

// Maps for config parsing
final _interestValues = {
  'hot': InterestLevel.hot,
  'warm': InterestLevel.warm,
  'cold': InterestLevel.cold
};

final _contactTypeValues = {
  'Client': ContactType.client,
  'Vendor': ContactType.vendor,
  'Partner': ContactType.partner,
  'Investor': ContactType.investor,
  'Other': ContactType.other,
};

final _dealStatusValues = {
  'Active': DealStatus.active,
  'Won': DealStatus.won,
  'Lost': DealStatus.lost,
  'Archived': DealStatus.archived,
};

// ─── Configs ──────────────────────────────────────────────────────────────────
const _contactTypeConfig = {
  ContactType.client:   (emoji: '🤝', label: 'Client',   color: Colors.blue),
  ContactType.vendor:   (emoji: '🏭', label: 'Vendor',   color: Colors.purple),
  ContactType.partner:  (emoji: '🤜', label: 'Partner',  color: Colors.teal),
  ContactType.investor: (emoji: '💰', label: 'Investor', color: Colors.green),
  ContactType.other:    (emoji: '👤', label: 'Other',    color: Colors.grey),
};
const _dealStatusConfig = {
  DealStatus.active:   (emoji: '🔥', label: 'Active',   color: Color(0xFF2563EB)),
  DealStatus.won:      (emoji: '🏆', label: 'Won',      color: Color(0xFF16A34A)),
  DealStatus.lost:     (emoji: '💔', label: 'Lost',     color: Color(0xFFDC2626)),
  DealStatus.archived: (emoji: '📦', label: 'Archived', color: Colors.grey),
};

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});
  @override ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  ContactType? _typeFilter;
  DealStatus? _statusFilter;
  bool _showAdd = false;
  final _audioPlayer = AudioPlayer();
  String? _playingTaskId;

  @override
  void dispose() {
    _searchCtrl.dispose();
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
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audio file not found.')));
        return;
      }
      setState(() => _playingTaskId = task.id);
      await _audioPlayer.play(DeviceFileSource(task.filePath));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _playingTaskId = null);
      });
    }
  }

  void _openAddConversation(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: AddConversationSheet(
            onConversationAdded: () => setState(() {}),
          ),
        ),
      ),
    );
  }

  void _openConversationDetail(BuildContext ctx, Conversation conv) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ConversationDetailSheet(
            conversation: conv, 
            formatCurrency: _formatCurrency(conv.businessSize),
          ),
        ),
      ),
    );
  }



  String _formatCurrency(String? vValue) {
    if (vValue == null || vValue.isEmpty) return '';
    final v = int.tryParse(vValue) ?? 0;
    if (v == 0) return '';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹$v';
  }

  List<Conversation> _getFiltered(List<Conversation> all) {
    return all.where((c) {
      final q = _searchQuery.toLowerCase();
      final name = c.contactName?.toLowerCase() ?? '';
      final project = c.projectName?.toLowerCase() ?? '';
      final company = c.contactCompany?.toLowerCase() ?? '';
      
      final matchesSearch = q.isEmpty || name.contains(q) || project.contains(q) || company.contains(q);
      
      final cType = _contactTypeValues[c.contactType] ?? ContactType.other;
      final matchesType = _typeFilter == null || cType == _typeFilter;
      
      final dStatus = _dealStatusValues[c.dealStatus] ?? DealStatus.active;
      final matchesStatus = _statusFilter == null || dStatus == _statusFilter;
      
      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncConversations = ref.watch(conversationsStreamProvider);
    final allConversations = asyncConversations.value ?? [];
    final filteredConversations = _getFiltered(allConversations);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              // ── Search bar ────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    prefixIcon: Icon(LucideIcons.search, size: 18, color: theme.colorScheme.onSurface.withAlpha(100)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Contact-type filter chips ──────────────────────────────────
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(label: 'All', selected: _typeFilter == null,
                      onTap: () => setState(() => _typeFilter = null)),
                    ...ContactType.values.map((t) {
                      final cfg = _contactTypeConfig[t]!;
                      final count = allConversations.where((c) => (_contactTypeValues[c.contactType] ?? ContactType.other) == t).length;
                      if (count == 0) return const SizedBox.shrink();
                      return _FilterChip(
                        label: '${cfg.emoji} ${cfg.label} ($count)',
                        selected: _typeFilter == t,
                        onTap: () => setState(() => _typeFilter = _typeFilter == t ? null : t),
                        color: cfg.color,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Deal-status filter chips ───────────────────────────────────
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(label: 'All Status', selected: _statusFilter == null,
                      onTap: () => setState(() => _statusFilter = null)),
                    ...DealStatus.values.map((s) {
                      final cfg = _dealStatusConfig[s]!;
                      final count = allConversations.where((c) => (_dealStatusValues[c.dealStatus] ?? DealStatus.active) == s).length;
                      if (count == 0) return const SizedBox.shrink();
                      return _FilterChip(
                        label: '${cfg.emoji} ${cfg.label} ($count)',
                        selected: _statusFilter == s,
                        onTap: () => setState(() => _statusFilter = _statusFilter == s ? null : s),
                        color: cfg.color,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // ── Background Queue Viewer ──────────────────────────────────
              Consumer(builder: (context, ref, child) {
                final tasks = ref.watch(backgroundProcessingProvider).where((t) => t.type == TaskType.chatInteraction).toList();
                if (tasks.isEmpty) return const SizedBox.shrink();
                
                return AeroCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Processing Audio Queues (${tasks.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                          TextButton(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            onPressed: () => ref.read(backgroundProcessingProvider.notifier).clearErrors(),
                            child: const Text('Clear Done', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...tasks.map((task) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: task.status == TaskStatus.processing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.audio_file),
                        title: Text(task.title, style: const TextStyle(fontSize: 13)),
                        subtitle: Text(task.status == TaskStatus.error ? '${task.status.name}: ${task.resultData ?? "Unknown"}' : (task.resultData ?? task.status.name), style: const TextStyle(fontSize: 11)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(_playingTaskId == task.id ? Icons.stop : Icons.play_arrow, size: 20),
                              onPressed: () => _togglePlay(task),
                            ),
                            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () {
                              ref.read(backgroundProcessingProvider.notifier).removeTask(task.id);
                            }),
                          ],
                        ),
                      )),
                    ],
                  ),
                );
              }),
              if (ref.watch(backgroundProcessingProvider).where((t) => t.type == TaskType.chatInteraction).isNotEmpty) const SizedBox(height: 16),

              // ── Conversation cards ─────────────────────────────────────────
              if (asyncConversations.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredConversations.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: Text('No conversations found', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(120)))),
                )
              else
                ...List.generate(filteredConversations.length, (i) {
                  final c = filteredConversations[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ConversationCard(
                      conversation: c,
                      formatCurrency: _formatCurrency,
                      onTap: () => _openConversationDetail(context, c),
                    ),
                  );
                }),
            ],
          ),

          // ── FAB ───────────────────────────────────────────────────────────
          Positioned(
            bottom: 100,
            right: 20,
            child: GestureDetector(
              onTap: () => _openAddConversation(context),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [const Color(0xFFef4444), theme.colorScheme.primary]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFFef4444).withAlpha(100), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: const Icon(LucideIcons.plus, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? c.withAlpha(30) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: c.withAlpha(100), width: 1.5) : null,
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12.5, fontWeight: FontWeight.w600,
          color: selected ? c : theme.colorScheme.onSurface.withAlpha(150),
        )),
      ),
    );
  }
}

// ─── Conversation Card ────────────────────────────────────────────────────────
class _ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final String Function(String?) formatCurrency;
  final VoidCallback onTap;
  const _ConversationCard({required this.conversation, required this.formatCurrency, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cType = _contactTypeValues[conversation.contactType] ?? ContactType.other;
    final dStatus = _dealStatusValues[conversation.dealStatus] ?? DealStatus.active;
    final isCfg = _contactTypeConfig[cType]!;
    final dsCfg = _dealStatusConfig[dStatus]!;

    // Interest color/icon
    final intLevel = _interestValues[conversation.interestLevel] ?? InterestLevel.warm;
    final (IconData icon, Color color, String label) = switch (intLevel) {
      InterestLevel.hot  => (LucideIcons.flame,     const Color(0xFFef4444), 'Hot'),
      InterestLevel.warm => (LucideIcons.sun,        AppColors.amber, 'Warm'),
      InterestLevel.cold => (LucideIcons.snowflake,  const Color(0xFF60A5FA), 'Cold'),
    };

    final name = conversation.contactName ?? 'Unknown';
    final initials = name.split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '').join().substring(0, 2.clamp(0, name.split(' ').length));

    final date = conversation.createdAt ?? DateTime.now();
    final timeStr = '${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
    final dateStr = '${_monthName(date.month)} ${date.day}';

    return GestureDetector(
      onTap: onTap,
      child: AeroCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + date row
                  Row(children: [
                    Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('$dateStr · $timeStr', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(120))),
                  ]),
                  const SizedBox(height: 2),
                  if (conversation.contactCompany != null) Text(conversation.contactCompany!, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140))),
                  const SizedBox(height: 4),
                  if (conversation.projectName != null) Text(conversation.projectName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  if (conversation.summary != null) Text(conversation.summary!, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),

                  // Status pills + interest + stars + amount
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    _StatusPill(label: '${dsCfg.emoji} ${dsCfg.label}', color: dsCfg.color),
                    _StatusPill(label: '${isCfg.emoji} ${isCfg.label}', color: isCfg.color),
                    _StatusPill(label: '$label', icon: icon, color: color),
                    Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) => Icon(
                      LucideIcons.star, size: 12,
                      color: i < (conversation.importance ?? 0) ? AppColors.amber : theme.colorScheme.onSurface.withAlpha(50),
                    ))),
                    Text(formatCurrency(conversation.businessSize), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  ]),

                  if (conversation.participants.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(children: [
                        Text('👥 ${conversation.participants.length} people', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(120))),
                      ]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) => const ['', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _StatusPill({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon!, size: 11, color: color), const SizedBox(width: 3)],
        Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}
