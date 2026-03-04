import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../widgets/aero_card.dart';
import '../../../theme/app_colors.dart';
import '../../../services/dashboard_service.dart';

class PipelineChartCard extends ConsumerWidget {
  const PipelineChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardProvider);
    
    final totalValue = dashboardData.pipelineTotal;
    final targetValue = dashboardData.targetTotal;
    double progressPercent = targetValue > 0 ? (totalValue / targetValue) * 100 : 0;
    if (progressPercent > 100) progressPercent = 100;
    
    // Formatting helper
    String formatLakhs(double val) {
      if (val >= 100000) {
        return '₹${(val / 100000).toStringAsFixed(1)}L';
      } else {
        return NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(val);
      }
    }

    final totalFormatted = formatLakhs(totalValue);
    final targetFormatted = formatLakhs(targetValue);
    final inProgressFormatted = formatLakhs(dashboardData.pipelineInProgress);
    final contractFormatted = formatLakhs(dashboardData.pipelineContract);
    final initialFormatted = formatLakhs(dashboardData.pipelineInitial);
    
    // Percentages for ring chart (safeguard against 0 division)
    double pContract = totalValue > 0 ? dashboardData.pipelineContract / totalValue : 0;
    double pInProgress = totalValue > 0 ? dashboardData.pipelineInProgress / totalValue : 0;
    double pInitial = totalValue > 0 ? dashboardData.pipelineInitial / totalValue : 0;
    
    return AeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROJECT PIPELINE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalFormatted Total',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Ring Chart Simulation
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: pContract > 0 ? pContract : 0.05, // Minimum visual indicator if none
                        strokeWidth: 20,
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: pInProgress > 0 ? pInProgress : 0.0,
                        strokeWidth: 20,
                        color: AppColors.amber,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: pInitial > 0 ? pInitial : 0.0,
                        strokeWidth: 20,
                        color: Theme.of(context).colorScheme.error,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              
              // Legend
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem(context, 'Contract', contractFormatted, Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    _buildLegendItem(context, 'In Progress', inProgressFormatted, AppColors.amber),
                    const SizedBox(height: 8),
                    _buildLegendItem(context, 'Initial', initialFormatted, Theme.of(context).colorScheme.error),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          // Target Bar
          Row(
            children: [
              Icon(LucideIcons.target, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              const Text(
                'FY TARGET',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                targetFormatted,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Target Progress Bar
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withAlpha(50),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercent / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      AppColors.amber,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progressPercent.toStringAsFixed(0)}% achieved',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                '${formatLakhs((targetValue - totalValue).clamp(0, targetValue))} to go',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
