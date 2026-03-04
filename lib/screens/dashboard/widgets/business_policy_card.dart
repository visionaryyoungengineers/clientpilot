import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../widgets/aero_card.dart';

class BusinessPolicyCard extends StatelessWidget {
  const BusinessPolicyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AeroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.shieldCheck, color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 10),
              const Text('Business Intelligence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                  child: Text('Score: A', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 240,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: theme.colorScheme.primary.withAlpha(50),
                    borderColor: theme.colorScheme.primary,
                    entryRadius: 4,
                    dataEntries: [
                      const RadarEntry(value: 85), // Revenue Predictability
                      const RadarEntry(value: 65), // Client Retention
                      const RadarEntry(value: 90), // Deal Velocity
                      const RadarEntry(value: 70), // Lead Conversion
                      const RadarEntry(value: 80), // Follow-up Discipline
                    ],
                    borderWidth: 2,
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: Colors.transparent),
                titlePositionPercentageOffset: 0.3,
                tickCount: 4,
                ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
                tickBorderData: BorderSide(color: theme.colorScheme.onSurface.withAlpha(40)),
                gridBorderData: BorderSide(color: theme.colorScheme.onSurface.withAlpha(40), width: 1.5),
                radarShape: RadarShape.polygon,
                getTitle: (index, angle) {
                  final titles = ['Predictability', 'Retention', 'Velocity', 'Conversion', 'Discipline'];
                  return RadarChartTitle(
                    text: titles[index],
                    angle: 0, // Keep titles upright
                  );
                },
                titleTextStyle: TextStyle(color: theme.colorScheme.onSurface, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeOutQuart,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your business policy analysis shows strong deal velocity and revenue predictability. Focus on improving client retention strategies to maximize lifetime value.',
            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(160), height: 1.4),
          ),
        ],
      ),
    );
  }
}
