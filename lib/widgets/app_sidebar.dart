import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../widgets/aero_card.dart';
import '../main.dart'; // To access themeModeProvider
import 'package:shared_preferences/shared_preferences.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 16,
      child: Column(
        children: [
          // Header Hero Section (matches Web)
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 24,
              left: 24,
              right: 24,
              bottom: 32,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'CP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Solo Pilot',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Free Plan',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(context, LucideIcons.messageSquare, 'Manage Conversations', () {
                  Navigator.pop(context);
                  context.go('/conversations');
                }),
                _buildMenuItem(context, LucideIcons.squareCheck, 'To-Do', () {
                  Navigator.pop(context);
                  context.go('/todo');
                }),
                _buildMenuItem(context, LucideIcons.radar, '⚡ Autopilot', () {
                  Navigator.pop(context);
                  context.push('/autopilot');
                }),
                _buildMenuItem(context, LucideIcons.users, 'Team Management', () {
                  Navigator.pop(context);
                  context.push('/team');
                }),
                _buildMenuItem(context, LucideIcons.userCog, 'Seat Management', () {
                  Navigator.pop(context);
                  context.push('/seats');
                }),
                _buildMenuItem(context, LucideIcons.landmark, '🏛 Govt. Schemes', () {
                  Navigator.pop(context);
                  context.push('/government-schemes');
                }),
                ListTile(
                  leading: Icon(LucideIcons.palette, color: Theme.of(context).colorScheme.onSurface.withAlpha(150), size: 20),
                  title: Text(
                    ref.watch(themeModeProvider) == ThemeMode.dark ? '☀️ Light Mode' : '🌙 Dark Mode',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                  onTap: () {
                    final current = ref.read(themeModeProvider);
                    ref.read(themeModeProvider.notifier).state = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                  },
                ),
                _buildMenuItem(context, LucideIcons.slidersHorizontal, 'Custom Fields', () {
                  Navigator.pop(context);
                  context.push('/custom-fields');
                }),
                _buildMenuItem(context, LucideIcons.target, 'Financial Year Target', () {
                  Navigator.pop(context); // close sidebar
                  _showFYTargetDialog(context);
                }),
                _buildMenuItem(context, LucideIcons.user, 'Edit Profile', () {
                  Navigator.pop(context);
                  context.go('/profile');
                }),
                _buildMenuItem(context, LucideIcons.userPlus, 'Invite Friends', () {
                  Navigator.pop(context);
                  context.push('/invite');
                }),
                _buildMenuItem(context, LucideIcons.trophy, 'Earn Badges', () {
                  Navigator.pop(context);
                  context.push('/badges');
                }),
                _buildMenuItem(context, LucideIcons.gamepad2, 'Games', () {
                  Navigator.pop(context);
                  context.push('/games');
                }),
                _buildMenuItem(context, LucideIcons.smile, 'Humor Level', () {
                  Navigator.pop(context);
                  _showHumorLevelDialog(context);
                }),
                _buildMenuItem(context, LucideIcons.lightbulb, 'Business Wisdom', () {
                  Navigator.pop(context);
                  _showBusinessWisdomDialog(context);
                }),
                _buildMenuItem(context, LucideIcons.circleArrowUp, 'Upgrade', () {
                  Navigator.pop(context);
                  context.push('/subscription');
                }),
                _buildMenuItem(context, LucideIcons.logOut, 'Logout', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFYTargetDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTarget = prefs.getDouble('dashboard_target') ?? 0.0;
    final ctrl = TextEditingController(text: currentTarget > 0 ? currentTarget.toStringAsFixed(0) : '');

    if (!context.mounted) return;
    showDialog(context: context, builder: (c) {
      return AlertDialog(
        title: const Text('Financial Year Target 🎯'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Set your revenue target for this financial year.'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Amount (e.g. 5000000)',
                prefixIcon: const Icon(LucideIcons.indianRupee, size: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final val = double.tryParse(ctrl.text.trim());
              if (val != null && val > 0) {
                await prefs.setDouble('dashboard_target', val);
                if (c.mounted) Navigator.pop(c);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Financial Target updated!')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    });
  }

  Future<void> _showHumorLevelDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    double currentLevel = prefs.getDouble('humor_level') ?? 5.0;

    if (!context.mounted) return;
    showDialog(context: context, builder: (c) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('AI Humor Level 🎭'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Set how much personality Qwen AI will use when analyzing your deals.'),
                const SizedBox(height: 16),
                Slider(
                  value: currentLevel,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  label: currentLevel.toInt().toString(),
                  onChanged: (val) {
                    setState(() => currentLevel = val);
                  },
                ),
                Text(
                  currentLevel < 4 ? 'Strict & Professional' : currentLevel < 8 ? 'Witty' : 'Unfiltered Chaos',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  await prefs.setDouble('humor_level', currentLevel);
                  if (c.mounted) Navigator.pop(c);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Humor level set to ${currentLevel.toInt()}!')));
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      );
    });
  }

  Future<void> _showBusinessWisdomDialog(BuildContext context) async {
    final quotes = [
      "The secret of getting ahead is getting started. - Mark Twain",
      "Don't find customers for your products, find products for your customers. - Seth Godin",
      "Strive not to be a success, but rather to be of value. - Albert Einstein",
      "Risk more than others think is safe. Dream more than others think is practical. - Howard Schultz",
      "The best way to predict the future is to create it. - Peter Drucker",
      "If you are not embarrassed by the first version of your product, you’ve launched too late. - Reid Hoffman"
    ];
    quotes.shuffle();
    final quote = quotes.first;

    if (!context.mounted) return;
    
    // Badge logic
    final prefs = await SharedPreferences.getInstance();
    int readCount = (prefs.getInt('wisdom_count') ?? 0) + 1;
    await prefs.setInt('wisdom_count', readCount);
    if (readCount >= 10 && !(prefs.getBool('badge_Wisdom Seeker') ?? false)) {
      await prefs.setBool('badge_Wisdom Seeker', true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🏆 Badge Unlocked: Wisdom Seeker!')));
      }
    }

    showDialog(context: context, builder: (c) {
      return AlertDialog(
        title: const Text('Daily Wisdom 🦉'),
        content: Text(
          quote, 
          style: const TextStyle(fontSize: 16, height: 1.5, fontStyle: FontStyle.italic),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Take Action'),
          ),
        ],
      );
    });
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withAlpha(150), size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      onTap: onTap,
    );
  }
}
