import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/aero_card.dart';
import '../../../theme/app_colors.dart';

class FollowUpAlertsCard extends StatelessWidget {
  final int criticalCount;
  final int totalCount;

  const FollowUpAlertsCard({
    super.key,
    required this.criticalCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return AeroCard(
      padding: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () {
          // Open FollowUps Sheet
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        criticalCount > 0 ? LucideIcons.triangleAlert : LucideIcons.clock,
                        color: criticalCount > 0 ? Theme.of(context).colorScheme.error : AppColors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Auto Follow-ups',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (criticalCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$criticalCount critical',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMockAlertItem(
                context,
                'Rohan Sharma',
                'Design Retainer',
                'Invoice overdue by 3 days.',
                Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 8),
              _buildMockAlertItem(
                context,
                'Anita Desk',
                'Website Revamp',
                'Waiting on asset approval.',
                Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockAlertItem(BuildContext context, String name, String project, String reason, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name — $project',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
