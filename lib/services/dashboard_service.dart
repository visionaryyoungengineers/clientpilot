import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'conversation_repository.dart';
import '../models/conversation.dart';

class DashboardData {
  final double pipelineTotal;
  final double targetTotal;
  final double pipelineInProgress;
  final double pipelineContract;
  final double pipelineInitial;

  // Pulse Metrics
  final int activeDeals;
  final int pendingFollowUps;
  final int conversationsThisWeek;

  DashboardData({
    this.pipelineTotal = 0,
    this.targetTotal = 50.0 * 100000.0, 
    this.pipelineInProgress = 0,
    this.pipelineContract = 0,
    this.pipelineInitial = 0,
    this.activeDeals = 0,
    this.pendingFollowUps = 0,
    this.conversationsThisWeek = 0,
  });
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardData>((ref) {
  return DashboardNotifier(ref);
});

class DashboardNotifier extends StateNotifier<DashboardData> {
  final Ref _ref;

  DashboardNotifier(this._ref) : super(DashboardData()) {
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = await _ref.read(conversationRepoProvider.future);
    final convs = await repo.getAll();

    double total = 0;
    double inProgress = 0;
    double contract = 0;
    double initial = 0;
    
    int active = 0;
    int pending = 0;
    int thisWeek = 0;
    
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    for (final c in convs) {
      if (c.createdAt != null && c.createdAt!.isAfter(weekAgo)) {
        thisWeek++;
      }
      
      if (c.revertBy != null && c.revertBy!.isBefore(now)) {
        // Simple logic: if there's a revert date in the past, it's a pending follow up
        pending++;
      }

      if (c.dealStatus == 'Lost' || c.dealStatus == 'Archived') continue;
      
      active++;

      final amount = c.dealAmount ?? 0.0;
      total += amount;

      // Simplistic mapping for the pipeline rings based on status
      if (c.dealStatus == 'Active') {
        if (c.interestLevel == 'hot') {
          contract += amount;
        } else if (c.interestLevel == 'warm') {
          inProgress += amount;
        } else {
          initial += amount;
        }
      } else if (c.dealStatus == 'Won') {
        contract += amount;
      }
    }

    // Get Target from SharedPreferences (could be editable later)
    final prefs = await SharedPreferences.getInstance();
    final target = prefs.getDouble('dashboard_target') ?? (50.0 * 100000.0);

    if (mounted) {
      state = DashboardData(
        pipelineTotal: total,
        targetTotal: target,
        pipelineInProgress: inProgress,
        pipelineContract: contract,
        pipelineInitial: initial,
        activeDeals: active,
        pendingFollowUps: pending,
        conversationsThisWeek: thisWeek,
      );
    }
  }

  void refresh() {
    _loadData();
  }
}
