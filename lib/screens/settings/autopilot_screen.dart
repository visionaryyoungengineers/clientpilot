import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../widgets/aero_card.dart';
import '../../theme/app_colors.dart';

class AutopilotScreen extends StatefulWidget {
  const AutopilotScreen({super.key});
  @override State<AutopilotScreen> createState() => _AutopilotScreenState();
}

class _AutopilotScreenState extends State<AutopilotScreen> {
  bool _isAutoMode = false;
  bool _isGenerating = false;

  static const _suggestions = [
    (name: 'Rohan Sharma', type: 'Follow Up', reason: 'No response in 3 days', draft: 'Hi Rohan, just checking in on the website proposal. Are you available for a quick call this week?'),
    (name: 'Anita Desai', type: 'Re-engage', reason: 'Conversation stale >7 days', draft: 'Hi Anita! Hope you\'re doing great. Wanted to revisit our mobile app discussion — any updates your end?'),
    (name: 'Kunal Mehta', type: 'Send Proposal', reason: 'Initial call completed', draft: 'Hi Kunal, as discussed, I\'ve attached the cloud migration proposal. Please review at your earliest convenience.'),
  ];

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Mode toggle card
          AeroCard(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.zap, color: Colors.white, size: 20)),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Auto Follow-up Pilot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Intelligent follow-up suggestions', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ])),
                Switch(value: _isAutoMode, onChanged: (v) => setState(() => _isAutoMode = v), activeColor: AppColors.primary),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _ModeChip(label: '💡 Suggest', selected: !_isAutoMode, onTap: () => setState(() => _isAutoMode = false)),
                const SizedBox(width: 10),
                _ModeChip(label: '🚀 Auto', selected: _isAutoMode, onTap: () => setState(() => _isAutoMode = true)),
              ]),
              const SizedBox(height: 10),
              Text(
                _isAutoMode ? 'Auto mode: Suggestions will be auto-sent (mocked — no actual messages sent).' : 'Suggest mode: Review each suggestion before acting.',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140)),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Generate button
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: _isGenerating ? null : () async {
              setState(() => _isGenerating = true);
              await Future.delayed(const Duration(milliseconds: 500)); // 500ms fake delay per PRD
              if (mounted) setState(() => _isGenerating = false);
            },
            icon: _isGenerating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(LucideIcons.refreshCw, size: 18),
            label: Text(_isGenerating ? 'Analysing...' : 'Generate Suggestions'),
          )),
          const SizedBox(height: 20),

          Text('SUGGESTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: theme.colorScheme.onSurface.withAlpha(120))),
          const SizedBox(height: 10),

          ..._suggestions.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SuggestionCard(suggestion: s),
          )),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _ModeChip({required this.label, required this.selected, required this.onTap});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withAlpha(25) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: theme.colorScheme.primary.withAlpha(100)) : null,
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(150))),
      ),
    );
  }
}

class _SuggestionCard extends StatefulWidget {
  final ({String name, String type, String reason, String draft}) suggestion;
  const _SuggestionCard({required this.suggestion});
  @override State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard> {
  bool _expanded = false;
  bool _dismissed = false;

  @override Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final s = widget.suggestion;
    final typeColor = s.type == 'Follow Up' ? AppColors.amber : s.type == 'Re-engage' ? AppColors.primary : const Color(0xFF16A34A);

    return AeroCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withAlpha(30), child: Text(s.name.split(' ').map((n) => n[0]).join().substring(0, 2), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            Text(s.reason, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140))),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: typeColor.withAlpha(25), borderRadius: BorderRadius.circular(12)),
            child: Text(s.type, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: typeColor))),
        ]),
        if (_expanded) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
            child: Text(s.draft, style: const TextStyle(fontSize: 13))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton.icon(icon: const Icon(LucideIcons.copy, size: 16), label: const Text('Copy'), onPressed: () {})),
            const SizedBox(width: 8),
            Expanded(child: FilledButton.icon(icon: const Icon(LucideIcons.send, size: 16), label: const Text('Send'), onPressed: () {})),
          ]),
        ],
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: () => setState(() => _dismissed = true), child: Text('Dismiss', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(120), fontSize: 13))),
          TextButton.icon(icon: Icon(_expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16), label: Text(_expanded ? 'Hide Draft' : 'View Draft'), onPressed: () => setState(() => _expanded = !_expanded)),
        ]),
      ]),
    );
  }
}
