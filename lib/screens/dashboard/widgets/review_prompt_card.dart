import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/aero_card.dart';

// Review Prompt – gently nudges user to request client reviews
class ReviewPromptCard extends StatefulWidget {
  const ReviewPromptCard({super.key});
  @override State<ReviewPromptCard> createState() => _ReviewPromptCardState();
}

class _ReviewPromptCardState extends State<ReviewPromptCard> {
  bool _dismissed = false;
  bool _copied = false;

  static const _template = 'Hi [Name], it was a pleasure working with you on [Project]. If you\'re happy with the results, would you mind leaving a quick review? It really helps small businesses like mine grow. Thank you! 🙏';

  @override Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return AeroCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(LucideIcons.star, color: const Color(0xFFf59e0b), size: 22),
          const SizedBox(width: 10),
          const Expanded(child: Text('Review Prompt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          IconButton(icon: Icon(LucideIcons.x, size: 18, color: theme.colorScheme.onSurface.withAlpha(100)), onPressed: () => setState(() => _dismissed = true)),
        ]),
        const SizedBox(height: 4),
        Text('Ask your recent client for a review 🌟', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(150))),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
          child: Text(_template, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.5)),
        ),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(child: OutlinedButton.icon(
            icon: Icon(_copied ? LucideIcons.check : LucideIcons.clipboardCopy, size: 16),
            label: Text(_copied ? 'Copied!' : 'Copy Template'),
            onPressed: () => setState(() => _copied = true),
          )),
          const SizedBox(width: 10),
          Expanded(child: FilledButton.icon(
            icon: const Icon(LucideIcons.send, size: 16),
            label: const Text('Send via WhatsApp'),
            onPressed: () {},
          )),
        ]),
      ]),
    );
  }
}
