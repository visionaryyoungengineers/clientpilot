import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/aero_card.dart';
import '../../../theme/app_colors.dart';

class ActionablesCard extends StatelessWidget {
  final int dueToday;
  final int overdue;
  final int upcoming;

  const ActionablesCard({
    super.key,
    required this.dueToday,
    required this.overdue,
    required this.upcoming,
  });

  @override
  Widget build(BuildContext context) {
    return AeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIONABLES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatBox(
                context,
                'Due Today',
                dueToday,
                LucideIcons.clock,
                AppColors.amber,
              ),
              const SizedBox(width: 8),
              _buildStatBox(
                context,
                'Overdue',
                overdue,
                LucideIcons.triangleAlert,
                Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              _buildStatBox(
                context,
                'Upcoming',
                upcoming,
                LucideIcons.calendarClock,
                Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
