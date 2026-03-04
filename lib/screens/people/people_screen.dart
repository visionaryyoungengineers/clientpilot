import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aero_card.dart';

class Person {
  final String id, name;
  final String? phone, email, company, bio;
  final List<String> roles, tags;
  final bool hasVoiceMemo;
  const Person({required this.id, required this.name, this.phone, this.email, this.company, this.bio, this.roles = const [], this.tags = const [], this.hasVoiceMemo = false});

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});
  @override State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  final List<Person> _people = [];

  List<Person> get _filtered => _people.where((p) {
    final q = _query.toLowerCase();
    return q.isEmpty || p.name.toLowerCase().contains(q) || (p.company?.toLowerCase().contains(q) ?? false) || (p.email?.toLowerCase().contains(q) ?? false);
  }).toList();

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 12, offset: const Offset(0, 4))]),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search people...',
                  prefixIcon: Icon(LucideIcons.search, size: 18, color: theme.colorScheme.onSurface.withAlpha(100)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Import from phone contacts
            GestureDetector(
              onTap: () => _importContacts(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.colorScheme.primary.withAlpha(40)),
                ),
                child: Row(children: [
                  Icon(LucideIcons.smartphoneNfc, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Text('Import from Phone Contacts', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                  const Spacer(),
                  Icon(LucideIcons.chevronRight, size: 16, color: theme.colorScheme.primary),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            Text('${_filtered.length} CONTACTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: theme.colorScheme.onSurface.withAlpha(120))),
            const SizedBox(height: 10),

            if (_filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No contacts found', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(120)))),
              )
            else
              ..._filtered.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PersonCard(person: p),
              )),
          ],
        ),

        // FAB
        Positioned(
          bottom: 100, right: 20,
          child: GestureDetector(
            onTap: () => _openAddSheet(context),
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: theme.colorScheme.primary.withAlpha(80), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Icon(LucideIcons.userPlus, color: Colors.white, size: 22),
            ),
          ),
        ),
      ]),
    );
  }

  void _importContacts(BuildContext context) async {
    try {
      // Request READ_CONTACTS permission at runtime first
      final permission = await FlutterContacts.requestPermission(readonly: true);
      if (!permission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contacts permission denied. Please enable it in Settings.')),
          );
        }
        return;
      }

      // Open native single-contact picker
      final contact = await FlutterContacts.openExternalPick();
      if (contact == null || !mounted) return;

      // Fetch full contact details with null safety
      Contact? full;
      try {
        full = await FlutterContacts.getContact(contact.id, withProperties: true);
      } catch (_) {
        full = null;
      }
      
      // Fallback: use the basic contact data returned by the picker itself
      final displayName = (full?.displayName?.isNotEmpty ?? false)
          ? full!.displayName
          : (contact.displayName.isNotEmpty ? contact.displayName : 'Unknown Contact');

      final rawPhone = (full?.phones.isNotEmpty ?? false)
          ? full!.phones.first.number
          : (contact.phones.isNotEmpty ? contact.phones.first.number : '');
      final cleanPhone = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');

      final email = (full?.emails.isNotEmpty ?? false)
          ? full!.emails.first.address
          : (contact.emails.isNotEmpty ? contact.emails.first.address : null);

      final exists = _people.any((p) =>
          p.phone != null && cleanPhone.isNotEmpty &&
          p.phone!.replaceAll(RegExp(r'[^\d+]'), '') == cleanPhone);

      if (exists && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$displayName is already in your list.')),
        );
        return;
      }

      if (mounted) {
        setState(() {
          _people.insert(0, Person(
            id: contact.id,
            name: displayName,
            phone: rawPhone.isNotEmpty ? rawPhone : null,
            email: email,
            roles: const ['Client'],
            tags: const ['phone-contact'],
          ));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $displayName to your contacts.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not import contact: $e')),
        );
      }
    }
  }


  void _openAddSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _AddPersonSheet(
        onAdd: (person) => setState(() => _people.add(person)),
      ),
    );
  }
}

// ─── Person Card ──────────────────────────────────────────────────────────────
class _PersonCard extends StatelessWidget {
  final Person person;
  const _PersonCard({required this.person});

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AeroCard(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(person.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(person.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          if (person.company != null)
            Text(person.company!, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(140))),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4, children: [
            ...person.roles.map((r) => _Chip(label: r, color: theme.colorScheme.primary)),
            ...person.tags.map((t) => _Chip(label: '# $t', color: theme.colorScheme.onSurface.withAlpha(100))),
          ]),
          if (person.hasVoiceMemo) ...[
            const SizedBox(height: 8),
            const _VoiceMemoPlayer(),
          ],
        ])),
        Column(children: [
          if (person.phone != null)
            IconButton(icon: Icon(LucideIcons.phone, size: 18, color: theme.colorScheme.primary), onPressed: () {}),
          if (person.email != null)
            IconButton(icon: Icon(LucideIcons.mail, size: 18, color: theme.colorScheme.primary), onPressed: () {}),
        ]),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label; final Color color;
  const _Chip({required this.label, required this.color});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(12)),
    child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );
}

class _VoiceMemoPlayer extends StatefulWidget {
  const _VoiceMemoPlayer();
  @override State<_VoiceMemoPlayer> createState() => _VoiceMemoPlayerState();
}

class _VoiceMemoPlayerState extends State<_VoiceMemoPlayer> {
  bool _isPlaying = false;
  double _progress = 0;

  void _togglePlay() async {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    while (_progress < 1.0 && _isPlaying) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() => _progress += 0.05);
    }
    if (mounted) setState(() { _isPlaying = false; _progress = 0; });
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(20), borderRadius: BorderRadius.circular(24)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: _togglePlay,
          child: Icon(_isPlaying ? LucideIcons.square : LucideIcons.play, size: 16, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80, height: 4,
          child: LinearProgressIndicator(
            value: _progress, backgroundColor: theme.colorScheme.primary.withAlpha(40),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text('0:14', style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

// ─── Add Person Sheet ─────────────────────────────────────────────────────────
const _availableRoles = ['Client', 'Vendor', 'Partner', 'Investor', 'Decision Maker', 'Referral', 'Team Member', 'Other'];

class _AddPersonSheet extends ConsumerStatefulWidget {
  final void Function(Person) onAdd;
  const _AddPersonSheet({required this.onAdd});
  @override ConsumerState<_AddPersonSheet> createState() => _AddPersonSheetState();
}

class _AddPersonSheetState extends ConsumerState<_AddPersonSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final List<String> _selectedRoles = [];
  final List<String> _tags = [];
  final Map<String, dynamic> _customValues = {};

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customFields = ref.watch(sectionCustomFieldsProvider('People'));
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurface.withAlpha(60), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text('Add Person', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _field('Full Name *', LucideIcons.user, _nameCtrl),
        const SizedBox(height: 10),
        _field('Phone', LucideIcons.phone, _phoneCtrl, keyboard: TextInputType.phone),
        const SizedBox(height: 10),
        _field('Email', LucideIcons.mail, _emailCtrl, keyboard: TextInputType.emailAddress),
        const SizedBox(height: 10),
        _field('Company', LucideIcons.building2, _companyCtrl),
        const SizedBox(height: 10),
        _field('Bio / Notes', LucideIcons.fileText, _bioCtrl, maxLines: 3),
        const SizedBox(height: 14),

        // Roles multi-select
        Text('Roles', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withAlpha(140))),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _availableRoles.map((r) {
          final sel = _selectedRoles.contains(r);
          return GestureDetector(
            onTap: () => setState(() => sel ? _selectedRoles.remove(r) : _selectedRoles.add(r)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? theme.colorScheme.primary.withAlpha(25) : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: sel ? Border.all(color: theme.colorScheme.primary.withAlpha(80)) : null,
              ),
              child: Text(r, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(150))),
            ),
          );
        }).toList()),
        const SizedBox(height: 14),

        // Tags
        Text('Tags', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withAlpha(140))),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _tagCtrl, decoration: _deco(context, 'Add tag...', LucideIcons.tag))),
          const SizedBox(width: 8),
          IconButton(icon: Icon(LucideIcons.plus, color: theme.colorScheme.primary), onPressed: () {
            final t = _tagCtrl.text.trim();
            if (t.isNotEmpty) { setState(() { _tags.add(t); _tagCtrl.clear(); }); }
          }),
        ]),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: _tags.map((t) => GestureDetector(onTap: () => setState(() => _tags.remove(t)), child: _Chip(label: '# $t ×', color: theme.colorScheme.onSurface.withAlpha(120)))).toList()),
        ],
        
        if (customFields.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Custom Fields', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withAlpha(140))),
          const SizedBox(height: 8),
          ...customFields.map((f) {
            if (f.type == 'Dropdown') {
              final opts = f.dropdownOptions?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? ['Option 1', 'Option 2'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DropdownButtonFormField<String>(
                  decoration: _deco(context, f.name, LucideIcons.listEnd),
                  value: _customValues[f.name],
                  items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                  onChanged: (v) => setState(() => _customValues[f.name] = v),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  initialValue: _customValues[f.name]?.toString() ?? '',
                  keyboardType: f.type == 'Number' ? TextInputType.number : TextInputType.text,
                  decoration: _deco(context, f.name, f.type == 'Number' ? LucideIcons.hash : LucideIcons.text),
                  onChanged: (v) => _customValues[f.name] = v,
                ),
              );
            }
          }),
        ],

        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty) return; // silent fail per PRD
            final p = Person(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _nameCtrl.text.trim(),
              phone: _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text, email: _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
              company: _companyCtrl.text.isEmpty ? null : _companyCtrl.text, bio: _bioCtrl.text.isEmpty ? null : _bioCtrl.text,
              roles: List.from(_selectedRoles), tags: List.from(_tags));
            
            if (_customValues.isNotEmpty) {
              p.customFieldsData = jsonEncode(_customValues);
            }
            
            widget.onAdd(p);
            Navigator.pop(context);
          },
          child: const Text('Save Contact'),
        )),
      ])),
    );
  }

  Widget _field(String hint, IconData icon, TextEditingController ctrl, {TextInputType? keyboard, int maxLines = 1}) => TextField(
    controller: ctrl, keyboardType: keyboard, maxLines: maxLines,
    decoration: _deco(context, hint, icon),
  );

  InputDecoration _deco(BuildContext ctx, String hint, IconData icon) => InputDecoration(
    hintText: hint, prefixIcon: Icon(icon, size: 18), filled: true,
    fillColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );
}
