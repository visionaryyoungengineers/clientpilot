import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/aero_card.dart';
import '../../../services/conversation_repository.dart';
import '../../../services/model_manager_service.dart';
import '../../../services/local_llm_service.dart';

class BusinessWisdomCard extends ConsumerStatefulWidget {
  const BusinessWisdomCard({super.key});
  @override ConsumerState<BusinessWisdomCard> createState() => _BusinessWisdomCardState();
}

class _BusinessWisdomCardState extends ConsumerState<BusinessWisdomCard> {
  bool _isLoading = true;
  String _wisdomTip = '';
  String _wisdomIcon = '💡';
  String _wisdomAuthor = 'ClientPilot AI';
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _loadDailyWisdom();
  }

  Future<void> _loadDailyWisdom() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('wisdom_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    // If we already generated one today, load it from cache
    if (lastDate == today) {
      setState(() {
        _wisdomTip = prefs.getString('wisdom_tip') ?? 'Nurture existing relationships daily.';
        _wisdomIcon = prefs.getString('wisdom_icon') ?? '🎯';
        _isLoading = false;
      });
      return;
    }

    try {
      final repo = await ref.read(conversationRepoProvider.future);
      final convs = await repo.getAll();
      
      String contextStr = 'No active deals. Provide general sales wisdom.';
      if (convs.isNotEmpty) {
        final active = convs.where((c) => c.dealStatus != 'Won' && c.dealStatus != 'Closed').take(3).map((c) => c.contactName).join(', ');
        if (active.isNotEmpty) contextStr = 'The user is currently working on deals with: $active. Provide advice on closing deals or following up.';
      }

      final llm = ref.read(llmServiceProvider);
      final modelPaths = ref.read(modelManagerProvider);
      await llm.loadModel(await modelPaths.getModelPath());
      
      final tip = await llm.generateBusinessWisdom(contextStr);
      
      // Cache it for the rest of the day
      await prefs.setString('wisdom_date', today);
      await prefs.setString('wisdom_tip', tip);
      await prefs.setString('wisdom_icon', '🧠');

      if (mounted) {
        setState(() {
          _wisdomTip = tip;
          _wisdomIcon = '🧠';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _wisdomTip = 'Keep pushing forward. Every "no" brings you closer to a "yes".';
          _wisdomIcon = '💪';
          _isLoading = false;
        });
      }
    }
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AeroCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(LucideIcons.lightbulb, color: const Color(0xFFf59e0b), size: 22),
          const SizedBox(width: 10),
          const Text('AI Business Wisdom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          if (_isLoading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        ]),
        const SizedBox(height: 16),

        if (_isLoading) ...[
          const SizedBox(height: 80, child: Center(child: Text('Generating today\'s insights...'))),
        ] else ...[
          Text(_wisdomIcon, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text('"$_wisdomTip"', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, height: 1.5)),
          const SizedBox(height: 6),
          Text('— $_wisdomAuthor', style: TextStyle(fontSize: 12, color: const Color(0xFFf59e0b), fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 16),

        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton(
            onPressed: () => setState(() { _liked = !_liked; }),
            icon: Icon(_liked ? LucideIcons.heart : LucideIcons.heart, color: _liked ? const Color(0xFFef4444) : theme.colorScheme.onSurface.withAlpha(100), size: 20),
          ),
        ]),
      ]),
    );
  }
}
