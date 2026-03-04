import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/aero_card.dart';

// Smart Insights – static array, shown with 1500ms fake loading delay per PRD
class SmartInsightsCard extends StatefulWidget {
  const SmartInsightsCard({super.key});
  @override State<SmartInsightsCard> createState() => _SmartInsightsCardState();
}

class _SmartInsightsCardState extends State<SmartInsightsCard> {
  bool _loading = false;
  bool _loaded = false;
  String? _copiedDraft;

  static const _insights = [
    (icon: '📈', text: 'Your follow-up conversion improved 23% this month — keep the momentum going!', type: 'Positive'),
    (icon: '⚠️', text: '3 clients haven\'t been contacted in over 14 days. Risk of losing interest.', type: 'Warning'),
    (icon: '💡', text: 'Tuesday mornings have your highest response rates. Schedule key outreach then.', type: 'Tip'),
    (icon: '🏆', text: 'You\'ve closed 2 deals this quarter. You\'re on track for your financial target.', type: 'Achievement'),
    (icon: '🔍', text: 'Your average deal size is ₹3.2L. Targeting one enterprise client could 5x this.', type: 'Insight'),
  ];

  static const _draftTemplates = [
    'Hi [Name], I noticed we haven\'t connected in a while. I have some exciting updates I\'d love to share — are you available for a quick call this week?',
    'Dear [Name], following up on our last discussion. We\'ve made great progress and I\'d love your input on the next steps.',
    'Hi [Name], just a quick check-in! Our team has been working on something I think you\'ll find very valuable. Can we connect?',
  ];

  void _loadInsights() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500)); // per PRD: 1500ms fake delay
    if (mounted) setState(() { _loading = false; _loaded = true; });
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AeroCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(LucideIcons.brain, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          const Text('Smart Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          if (!_loaded && !_loading) TextButton(onPressed: _loadInsights, child: const Text('Generate')),
        ]),
        const SizedBox(height: 12),

        if (!_loaded && !_loading) ...[
          Center(child: Column(children: [
            const SizedBox(height: 12),
            Icon(LucideIcons.sparkles, size: 40, color: theme.colorScheme.primary.withAlpha(100)),
            const SizedBox(height: 8),
            Text('Click Generate for AI-powered insights', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(130), fontSize: 13)),
            Text('(Static analysis — no model calls)', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(80), fontSize: 11)),
            const SizedBox(height: 12),
          ])),
        ],

        if (_loading) ...[
          Center(child: Column(children: [
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text('Analysing your data...', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(130))),
            const SizedBox(height: 12),
          ])),
        ],

        if (_loaded) ...[
          ..._insights.asMap().entries.map((e) {
            final ins = e.value;
            final typeColor = ins.type == 'Positive' || ins.type == 'Achievement'
                ? const Color(0xFF16A34A)
                : ins.type == 'Warning' ? const Color(0xFFef4444) : theme.colorScheme.primary;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: typeColor.withAlpha(12), borderRadius: BorderRadius.circular(12), border: Border.all(color: typeColor.withAlpha(40))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(ins.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: typeColor.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                      child: Text(ins.type, style: TextStyle(fontSize: 10, color: typeColor, fontWeight: FontWeight.bold))),
                  ]),
                  const SizedBox(height: 6),
                  Text(ins.text, style: const TextStyle(fontSize: 13, height: 1.4)),
                ]),
              ),
            );
          }),

          // Copy draft action
          const Divider(),
          const SizedBox(height: 8),
          Row(children: [
            Icon(LucideIcons.clipboardCopy, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text('Copy draft message', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
            const Spacer(),
            if (_copiedDraft != null) const Icon(LucideIcons.check, size: 14, color: Color(0xFF16A34A)),
          ]),
          if (_copiedDraft == null)
            Wrap(spacing: 8, runSpacing: 8, children: List.generate(_draftTemplates.length, (i) => GestureDetector(
              onTap: () => setState(() => _copiedDraft = _draftTemplates[i]),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(15), borderRadius: BorderRadius.circular(14)),
                child: Text('Draft ${i + 1}', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.w600))),
            ))),
          if (_copiedDraft != null) ...[
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
              child: Text(_copiedDraft!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic))),
          ],
        ],
      ]),
    );
  }
}
