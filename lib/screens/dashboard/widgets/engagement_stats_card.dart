import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/aero_card.dart';

// Engagement Stats – shows conversation, follow-up, and deal metrics
class EngagementStatsCard extends StatelessWidget {
  const EngagementStatsCard({super.key});

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AeroCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(LucideIcons.chartBar, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          const Text('Engagement Stats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          Text('This Month', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(120))),
        ]),
        const SizedBox(height: 16),

        // Stat row 1
        Row(children: [
          Expanded(child: _StatBox(label: 'Conversations', value: '12', change: '+3', positive: true, icon: LucideIcons.messageSquare)),
          const SizedBox(width: 10),
          Expanded(child: _StatBox(label: 'Follow-ups Sent', value: '8', change: '+1', positive: true, icon: LucideIcons.send)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _StatBox(label: 'Deals Won', value: '2', change: '+2', positive: true, icon: LucideIcons.trophy)),
          const SizedBox(width: 10),
          Expanded(child: _StatBox(label: 'Deals Lost', value: '1', change: '-1', positive: false, icon: LucideIcons.x)),
        ]),
        const SizedBox(height: 16),

        // Response rate bar
        Text('Avg. Response Rate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withAlpha(160))),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 0.68, minHeight: 10, backgroundColor: theme.colorScheme.surfaceContainerHighest, valueColor: const AlwaysStoppedAnimation(Color(0xFF16A34A))))),
          const SizedBox(width: 10),
          const Text('68%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value, change; final bool positive; final IconData icon;
  const _StatBox({required this.label, required this.value, required this.change, required this.positive, required this.icon});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = positive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(150)), overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Container(margin: const EdgeInsets.only(bottom: 2), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: c.withAlpha(20), borderRadius: BorderRadius.circular(8)), child: Text(change, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.bold))),
        ]),
      ]),
    );
  }
}
