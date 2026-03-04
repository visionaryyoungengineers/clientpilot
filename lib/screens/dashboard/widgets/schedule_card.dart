import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/aero_card.dart';

// Schedule Widget – upcoming tasks/meetings for the week
class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key});

  static final _items = [
    _ScheduleItem(time: 'Today 10:00', title: 'Call with Rohan — Website proposal review', type: 'Call', isDone: false),
    _ScheduleItem(time: 'Today 14:30', title: 'Send revised MOU to Priya', type: 'Task', isDone: false),
    _ScheduleItem(time: 'Tomorrow 09:00', title: 'Follow-up with Anita post demo', type: 'Follow-up', isDone: false),
    _ScheduleItem(time: 'Thu 11:00', title: 'Cloud migration assessment call – Kunal', type: 'Call', isDone: false),
    _ScheduleItem(time: 'Fri 17:00', title: 'Invoice due — Priya ERP Integration', type: 'Reminder', isDone: false),
  ];

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AeroCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(LucideIcons.calendarDays, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          const Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          Text('This Week', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 14),
        ..._items.map((item) => _ScheduleRow(item: item)),
      ]),
    );
  }
}

class _ScheduleItem {
  final String time, title, type;
  final bool isDone;
  const _ScheduleItem({required this.time, required this.title, required this.type, required this.isDone});
}

class _ScheduleRow extends StatelessWidget {
  final _ScheduleItem item;
  const _ScheduleRow({required this.item});

  Color _typeColor(BuildContext ctx) => switch (item.type) {
    'Call'      => const Color(0xFF2563EB),
    'Follow-up' => const Color(0xFFf59e0b),
    'Reminder'  => const Color(0xFFDC2626),
    _           => Theme.of(ctx).colorScheme.primary,
  };

  IconData _typeIcon() => switch (item.type) {
    'Call'      => LucideIcons.phone,
    'Follow-up' => LucideIcons.refreshCw,
    'Reminder'  => LucideIcons.bell,
    _           => LucideIcons.squareCheck,
  };

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = _typeColor(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: c.withAlpha(20), borderRadius: BorderRadius.circular(10)), child: Icon(_typeIcon(), size: 16, color: c)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          Row(children: [
            Icon(LucideIcons.clock, size: 11, color: theme.colorScheme.onSurface.withAlpha(120)),
            const SizedBox(width: 4),
            Text(item.time, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(120))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: c.withAlpha(15), borderRadius: BorderRadius.circular(8)), child: Text(item.type, style: TextStyle(fontSize: 10, color: c, fontWeight: FontWeight.bold))),
          ]),
        ])),
      ]),
    );
  }
}
