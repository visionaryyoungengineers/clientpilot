import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/actionables_card.dart';
import 'widgets/follow_up_alerts_card.dart';
import 'widgets/pipeline_chart_card.dart';
import 'widgets/business_pulse_card.dart';
import 'widgets/business_wisdom_card.dart';
import 'widgets/smart_insights_card.dart';
import 'widgets/schedule_card.dart';
import 'widgets/engagement_stats_card.dart';
import 'widgets/review_prompt_card.dart';
import 'widgets/business_policy_card.dart';
import '../onboarding/stt_download_sheet.dart';
import '../../services/model_manager_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../services/actionables_service.dart';
import '../../services/dashboard_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Widget visibility toggles (per PRD — stored in local state, no animation)
  final Map<String, bool> _visibility = {
    'business_pulse': true,
    'actionables': true,
    'follow_up_alerts': true,
    'pipeline_chart': true,
    'business_wisdom': true,
    'schedule': true,
    'engagement_stats': true,
    'review_prompt': true,
    'smart_insights': true,
    'business_policy': true,
  };

  bool _showCustomise = false;

  static const _widgetLabels = {
    'business_pulse': '💓 Business Pulse',
    'actionables': '✅ Actionables',
    'follow_up_alerts': '🚨 Follow-Up Alerts',
    'pipeline_chart': '📊 Pipeline Chart',
    'business_wisdom': '💡 Business Wisdom',
    'schedule': '📅 Schedule',
    'engagement_stats': '📈 Engagement Stats',
    'review_prompt': '⭐ Review Prompt',
    'smart_insights': '🧠 Smart Insights',
    'business_policy': '🛡️ Business Policy',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOnboardingAndPromptModel());
  }

  Future<void> _checkOnboardingAndPromptModel() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Check Onboarding first
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    if (!onboardingComplete) {
      if (mounted) context.go('/onboarding');
      return; // Stop here if intercepting for onboarding
    }
    
    // 2. Otherwise handle STT download prompt
    final alreadyDownloaded = prefs.getBool('stt_model_downloaded') ?? false;
    if (alreadyDownloaded) return; // skip — model is already on disk
    
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SttDownloadSheet(
        onComplete: () => Navigator.pop(ctx),
      ),
    );
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboardData = ref.watch(dashboardProvider);
    final allActionables = ref.watch(actionablesProvider);
    
    final pendingActionables = allActionables.where((a) => !a.isCompleted).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int dueToday = 0;
    int overdue = 0;
    int upcoming = 0;
    
    for (var act in pendingActionables) {
      if (act.dueDate == null) {
        upcoming++;
      } else {
        final d = act.dueDate!;
        final actDate = DateTime(d.year, d.month, d.day);
        if (actDate.isBefore(today)) overdue++;
        else if (actDate.isAtSameMomentAs(today)) dueToday++;
        else upcoming++;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 100),
          children: [
            // Customise strip
            GestureDetector(
              onTap: () => setState(() => _showCustomise = !_showCustomise),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(12), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(LucideIcons.settings2, size: 15, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Customise Dashboard', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                  const Spacer(),
                  Icon(_showCustomise ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 14, color: theme.colorScheme.primary),
                ]),
              ),
            ),

            // Customise toggles panel
            if (_showCustomise) ...[
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)]),
                child: Column(children: _widgetLabels.entries.map((e) => Row(children: [
                  Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13))),
                  Switch(value: _visibility[e.key]!, onChanged: (v) => setState(() => _visibility[e.key] = v), activeColor: theme.colorScheme.primary),
                ])).toList()),
              ),
            ],

            // ── Widgets in order ───────────────────────────────────────────
            if (_visibility['business_pulse']!) ...[const BusinessPulseCard(), const SizedBox(height: 16)],
            if (_visibility['actionables']!) ...[ActionablesCard(dueToday: dueToday, overdue: overdue, upcoming: upcoming), const SizedBox(height: 16)],
            if (_visibility['follow_up_alerts']!) ...[FollowUpAlertsCard(criticalCount: dashboardData.pendingFollowUps, totalCount: dashboardData.pendingFollowUps + (dashboardData.activeDeals > 0 ? 1 : 0)), const SizedBox(height: 16)],
            if (_visibility['pipeline_chart']!) ...[const PipelineChartCard(), const SizedBox(height: 16)],
            if (_visibility['schedule']!) ...[const ScheduleCard(), const SizedBox(height: 16)],
            if (_visibility['engagement_stats']!) ...[const EngagementStatsCard(), const SizedBox(height: 16)],
            if (_visibility['business_wisdom']!) ...[const BusinessWisdomCard(), const SizedBox(height: 16)],
            if (_visibility['review_prompt']!) ...[const ReviewPromptCard(), const SizedBox(height: 16)],
            if (_visibility['smart_insights']!) ...[const SmartInsightsCard(), const SizedBox(height: 16)],
            if (_visibility['business_policy']!) ...[const BusinessPolicyCard(), const SizedBox(height: 16)],
          ],
        ),
      ]),
    );
  }
}


