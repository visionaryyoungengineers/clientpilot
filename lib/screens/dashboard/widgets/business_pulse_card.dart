import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/aero_card.dart';
import '../../../services/dashboard_service.dart';

// Business Pulse – shows a "CRM health score" based on local stats
class BusinessPulseCard extends ConsumerWidget {
  const BusinessPulseCard({super.key});

  int _calculateScore(int pendingFollowUps, int conversationsThisWeek, int activeDeals) {
    int s = 100;
    if (pendingFollowUps > 5) s -= 20;
    else if (pendingFollowUps > 2) s -= 10;
    if (conversationsThisWeek < 2) s -= 15;
    if (activeDeals == 0) s -= 25;
    return s.clamp(0, 100);
  }

  Color _scoreColor(int s) {
    if (s >= 80) return const Color(0xFF16A34A);
    if (s >= 60) return const Color(0xFFf59e0b);
    return const Color(0xFFDC2626);
  }

  String _scoreLabel(int s) {
    if (s >= 80) return '💪 Excellent';
    if (s >= 60) return '👍 Good';
    return '⚠️ Needs Attention';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(dashboardProvider);
    
    final score = _calculateScore(data.pendingFollowUps, data.conversationsThisWeek, data.activeDeals);
    final color = _scoreColor(score);
    return AeroCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(LucideIcons.heartPulse, color: color, size: 22),
          const SizedBox(width: 10),
          Text('Business Pulse', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(12)),
            child: Text(_scoreLabel(score), style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 16),

        // Score ring
        Center(child: Stack(alignment: Alignment.center, children: [
          SizedBox(width: 100, height: 100,
            child: CircularProgressIndicator(value: score / 100, strokeWidth: 10, backgroundColor: theme.colorScheme.surfaceContainerHighest, valueColor: AlwaysStoppedAnimation(color))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$score', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text('/100', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(120))),
          ]),
        ])),
        const SizedBox(height: 16),

        // Stats row
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _Stat('💬', '${data.conversationsThisWeek}', 'This week'),
          _Stat('📌', '${data.pendingFollowUps}', 'Follow-ups'),
          _Stat('🤝', '${data.activeDeals}', 'Active deals'),
        ]),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji, value, label;
  const _Stat(this.emoji, this.value, this.label);
  @override Widget build(BuildContext context) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 20)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withAlpha(130))),
  ]);
}
