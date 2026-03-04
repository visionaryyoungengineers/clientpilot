import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aero_card.dart';
import '../../services/custom_field_service.dart';

class CustomFieldsScreen extends ConsumerWidget {
  const CustomFieldsScreen({super.key});

  void _addField(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (ctx) {
      String name = '';
      String type = 'Text';
      String section = 'People';
      return AlertDialog(
        title: const Text('Add Custom Field'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Field Name'),
            onChanged: (v) => name = v,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: type,
            items: ['Text', 'Number', 'Date', 'Dropdown'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) { if (v != null) type = v; },
            decoration: const InputDecoration(labelText: 'Data Type'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: section,
            items: ['People', 'To-Do', 'Chat'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) { if (v != null) section = v; },
            decoration: const InputDecoration(labelText: 'Target Section', helperText: 'Where should this field appear?'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (name.trim().isNotEmpty) {
              ref.read(customFieldsProvider.notifier).addField(
                name: name.trim(),
                type: type,
                section: section,
              );
              Navigator.pop(ctx);
            }
          }, child: const Text('Add')),
        ],
      );
    });
  }

  @override Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customFields = ref.watch(customFieldsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Manage Custom Fields', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Define additional fields to gather specialized context per client profile, chat, or actionable.', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 13)),
          const SizedBox(height: 24),
          
          if (customFields.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(child: Text('No custom fields yet.', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(120)))),
            )
          else
            ...customFields.map((field) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AeroCard(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(field.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Type: ${field.type} • Section: ${field.section}', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(140), fontSize: 13)),
                   ])),
                   IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () {
                     ref.read(customFieldsProvider.notifier).deleteField(field.uuid);
                   }),
                ]),
              ),
            )),
            
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Field'),
                onPressed: () => _addField(context, ref),
              ),
            ),
        ],
      ),
    );
  }
}
