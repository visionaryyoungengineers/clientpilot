import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:isar/isar.dart';
import '../../widgets/aero_card.dart';
import '../../models/team_member.dart';
import '../../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});
  @override ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  final _emailCtrl = TextEditingController();
  List<TeamMember> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final isar = await ref.read(isarProvider.future);
    final members = await isar.teamMembers.where().findAll();
    
    // Auto-seed the owner if the list is completely empty
    if (members.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final ownerName = prefs.getString('profile_name') ?? 'You';
      final ownerEmail = 'owner@workspace.com'; // Mock owner email if not auth
      
      final owner = TeamMember()
        ..name = ownerName
        ..email = ownerEmail
        ..role = 'Owner'
        ..status = 'active'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.teamMembers.put(owner);
      });
      members.add(owner);
    }

    // Sort: Owners first, then by creation date
    members.sort((a, b) {
      if (a.role == 'Owner' && b.role != 'Owner') return -1;
      if (a.role != 'Owner' && b.role == 'Owner') return 1;
      return a.createdAt.compareTo(b.createdAt);
    });

    if (mounted) {
      setState(() {
        _members = members;
        _isLoading = false;
      });
    }
  }

  Future<void> _inviteMember() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;

    final isar = await ref.read(isarProvider.future);
    
    final newMember = TeamMember()
      ..name = email.split('@').first
      ..email = email
      ..role = 'Member'
      ..status = 'invited'
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.teamMembers.put(newMember);
    });

    Share.share('Join ClientPilot to manage our clients together! Download the app: https://clientpilot.example.com/invite');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation saved and Share Dialog opened.')));
      _emailCtrl.clear();
      _loadMembers();
    }
  }

  Future<void> _removeMember(TeamMember member) async {
    if (member.role == 'Owner') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot remove the workspace owner.')));
      return;
    }

    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.teamMembers.delete(member.id);
    });
    
    _loadMembers();
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Seat info card
          AeroCard(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(20), borderRadius: BorderRadius.circular(12)), child: Icon(LucideIcons.users, color: theme.colorScheme.primary, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Team Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('\${_members.length} / 5 seats used', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(140))),
                ])),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: _members.length / 5, minHeight: 8, backgroundColor: theme.colorScheme.surfaceContainerHighest, valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary)),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Invite section
          AeroCard(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Invite a Member', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 4),
              Text('No OTP or email verification required (demo mode)', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(120))),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(
                  controller: _emailCtrl, 
                  keyboardType: TextInputType.emailAddress, 
                  decoration: InputDecoration(
                    hintText: 'Enter email address', filled: true, fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(LucideIcons.mail, size: 18), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  onSubmitted: (_) => _inviteMember(),
                )),
                const SizedBox(width: 10),
                FilledButton.icon(
                  icon: const Icon(LucideIcons.userPlus, size: 16),
                  label: const Text('Invite'),
                  onPressed: _members.length >= 5 ? null : _inviteMember, // cap at 5
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          Text('MEMBERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: theme.colorScheme.onSurface.withAlpha(120))),
          const SizedBox(height: 10),

          ..._members.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MemberCard(
              member: m,
              onRemove: () => _removeMember(m),
            ),
          )),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onRemove;
  const _MemberCard({required this.member, required this.onRemove});

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwner = member.role == 'Owner';
    final isActive = member.status == 'active';
    return AeroCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        CircleAvatar(radius: 22, backgroundColor: theme.colorScheme.primary.withAlpha(30), child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(member.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(width: 6),
            if (isOwner) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(20), borderRadius: BorderRadius.circular(8)), child: Text('Owner', style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
          ]),
          Text(member.email, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(130))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: (isActive ? const Color(0xFF16A34A) : const Color(0xFFf59e0b)).withAlpha(20), borderRadius: BorderRadius.circular(10)),
          child: Text(isActive ? 'Active' : 'Invited', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF16A34A) : const Color(0xFFf59e0b))),
        ),
        if (!isOwner) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 18),
            color: Colors.red.withAlpha(200),
            onPressed: onRemove,
            tooltip: 'Remove',
          )
        ],
      ]),
    );
  }
}
