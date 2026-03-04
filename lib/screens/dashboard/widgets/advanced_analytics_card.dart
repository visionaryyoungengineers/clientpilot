import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/aero_card.dart';

// Advanced Analytics – bar chart + funnel summary
class AdvancedAnalyticsCard extends StatelessWidget {
  const AdvancedAnalyticsCard({super.key});

  static const _months = ['Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb'];
  static const _revenue = [120000, 185000, 154000, 230000, 198000, 275000];

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxRevenue = _revenue.reduce((a, b) => a > b ? a : b);

    return AeroCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(LucideIcons.trendingUp, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          const Text('Advanced Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          Text('6 Months', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(120))),
        ]),
        const SizedBox(height: 20),

        // Bar chart
        Text('Monthly Revenue (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withAlpha(150))),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_months.length, (i) {
              final barH = (_revenue[i] / maxRevenue) * 100;
              final isMax = _revenue[i] == maxRevenue;
              return Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (isMax) Text('₹${(_revenue[i] / 1000).round()}K', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  const SizedBox(height: 2),
                  AnimatedContainer(duration: const Duration(milliseconds: 800), height: barH, decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: isMax ? [theme.colorScheme.primary, theme.colorScheme.secondary] : [theme.colorScheme.primary.withAlpha(100), theme.colorScheme.primary.withAlpha(50)]),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  )),
                  const SizedBox(height: 4),
                  Text(_months[i], style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withAlpha(120))),
                ]),
              ));
            }),
          ),
        ),
        const SizedBox(height: 20),

        // Funnel
        Text('Deal Funnel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withAlpha(150))),
        const SizedBox(height: 10),
        _FunnelRow(label: 'Leads', count: 24, total: 24, color: theme.colorScheme.primary),
        _FunnelRow(label: 'Prospects', count: 16, total: 24, color: const Color(0xFF0284c7)),
        _FunnelRow(label: 'Proposals', count: 9, total: 24, color: const Color(0xFFf59e0b)),
        _FunnelRow(label: 'Closed', count: 5, total: 24, color: const Color(0xFF16A34A)),
      ]),
    );
  }
}

class _FunnelRow extends StatelessWidget {
  final String label; final int count, total; final Color color;
  const _FunnelRow({required this.label, required this.count, required this.total, required this.color});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(160)))),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: count / total, minHeight: 8, backgroundColor: theme.colorScheme.surfaceContainerHighest, valueColor: AlwaysStoppedAnimation(color)))),
        const SizedBox(width: 8),
        Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}
