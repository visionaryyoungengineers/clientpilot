import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../widgets/aero_card.dart';
import '../../theme/app_colors.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isPro = false;
  bool _isProcessing = false;

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Current Plan Badge
          AeroCard(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
                gradient: _isPro ? const LinearGradient(colors: [Color(0xFFf59e0b), Color(0xFFef4444)]) : LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                borderRadius: BorderRadius.circular(12),
              ), child: Icon(_isPro ? LucideIcons.crown : LucideIcons.zap, color: Colors.white, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current Plan', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140))),
                Text(_isPro ? 'ClientPilot Pro ✨' : 'Free Plan', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_isPro) Text('Renews on 1 Apr 2026', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(120))),
              ])),
              if (_isPro) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF16A34A).withAlpha(25), borderRadius: BorderRadius.circular(12)), child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.bold))),
            ]),
          ),
          const SizedBox(height: 20),

          // Plan cards
          _PlanCard(
            name: 'Free',
            price: '₹0',
            period: 'forever',
            features: const ['Unlimited conversations (local)', '5 team seats', 'Basic AI features', 'Govt. schemes directory', 'Mini-games & badges'],
            isCurrentPlan: !_isPro,
            onSelect: _isPro ? () => setState(() => _isPro = false) : null,
          ),
          const SizedBox(height: 12),
          _PlanCard(
            name: 'Pro',
            price: '₹499',
            period: 'per month',
            features: const ['Everything in Free', 'Priority AI processing', 'Advanced analytics', 'Custom fields (unlimited)', 'P2P multi-device sync', 'White-label client portal', 'Priority support'],
            isCurrentPlan: _isPro,
            isPro: true,
            onSelect: !_isPro ? () => _handleUpgrade(context) : null,
          ),
          const SizedBox(height: 20),

          // Razorpay note (mocked)
          if (!_isPro) ...[
            Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(LucideIcons.shieldCheck, size: 14, color: theme.colorScheme.onSurface.withAlpha(100)),
              const SizedBox(width: 6),
              Text('Secured by Razorpay • Cancel anytime', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(100))),
            ])),
          ],
        ],
      ),
    );
  }

  void _handleUpgrade(BuildContext context) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() { _isProcessing = false; _isPro = true; }); // mock success
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Welcome to ClientPilot Pro!')));
  }
}

class _PlanCard extends StatelessWidget {
  final String name, price, period;
  final List<String> features;
  final bool isCurrentPlan, isPro;
  final VoidCallback? onSelect;

  const _PlanCard({required this.name, required this.price, required this.period, required this.features, required this.isCurrentPlan, this.isPro = false, this.onSelect});

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isCurrentPlan ? theme.colorScheme.primary : theme.colorScheme.outline.withAlpha(50), width: isCurrentPlan ? 2 : 1),
        color: theme.colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              if (isPro) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFf59e0b), Color(0xFFef4444)]), borderRadius: BorderRadius.circular(10)), child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))],
            ]),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
              const SizedBox(width: 4),
              Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('/$period', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(140)))),
            ]),
          ]),
          const Spacer(),
          if (isCurrentPlan) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(20), borderRadius: BorderRadius.circular(12)), child: Text('Current', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13))),
        ]),
        const SizedBox(height: 14),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Icon(LucideIcons.check, size: 16, color: const Color(0xFF16A34A)),
            const SizedBox(width: 8),
            Text(f, style: const TextStyle(fontSize: 14)),
          ]),
        )),
        if (onSelect != null) ...[
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: onSelect,
            style: isPro ? FilledButton.styleFrom(backgroundColor: null) : null,
            child: Text(isPro ? '✨ Upgrade to Pro' : 'Switch to Free'),
          )),
        ],
      ]),
    );
  }
}
