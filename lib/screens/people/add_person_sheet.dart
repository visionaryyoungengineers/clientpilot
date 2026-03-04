import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/aero_cta.dart';
import '../../theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../services/database_service.dart';
import '../../models/contact.dart' as app_contact;

class AddPersonSheet extends ConsumerStatefulWidget {
  final VoidCallback? onPersonAdded;
  const AddPersonSheet({super.key, this.onPersonAdded});

  @override
  ConsumerState<AddPersonSheet> createState() => _AddPersonSheetState();
}

class _AddPersonSheetState extends ConsumerState<AddPersonSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final List<String> _availableRoles = [
    'client', 'lead', 'supplier', 'employee', 'associate', 'other'
  ];
  final Set<String> _selectedRoles = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _importFromPhone() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final Contact? contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          // CRITICAL: withProperties:true fetches phones/organizations
          final fullContact = await FlutterContacts.getContact(
            contact.id,
            withProperties: true,
            withPhoto: false,
          );
          if (fullContact != null && mounted) {
            setState(() {
              _nameController.text = fullContact.displayName;
              if (fullContact.phones.isNotEmpty) {
                _phoneController.text = fullContact.phones.first.number;
              }
              if (fullContact.organizations.isNotEmpty) {
                _companyController.text = fullContact.organizations.first.company;
              }
              if (fullContact.emails.isNotEmpty) {
                // pre-fill bio with email so user can see it
                if (_bioController.text.isEmpty) {
                  _bioController.text = fullContact.emails.first.address;
                }
              }
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not import contact: $e')),
        );
      }
    }
  }

  Future<void> _savePerson() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    
    try {
      final isar = await DatabaseService.instance;
      final newContact = app_contact.Contact()
        ..uuid = const Uuid().v4()
        ..name = _nameController.text.trim()
        ..phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim()
        ..company = _companyController.text.trim().isEmpty ? null : _companyController.text.trim()
        ..bio = _bioController.text.trim().isEmpty ? null : _bioController.text.trim()
        ..roles = _selectedRoles.toList()
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await isar.writeTxn(() async => isar.contacts.put(newContact));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    }
    
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.of(context).pop();
      widget.onPersonAdded?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add Person',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(LucideIcons.x, color: AppColors.mutedForeground),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Import Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _importFromPhone,
            icon: Icon(LucideIcons.contact, size: 18),
            label: const Text('Import from Phone Contacts'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Name & Phone
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _companyController,
          decoration: InputDecoration(
            labelText: 'Company (Optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        
        const SizedBox(height: 24),
        const Text('Roles & Relationships', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _availableRoles.map((role) {
            final isSelected = _selectedRoles.contains(role);
            return FilterChip(
              label: Text(role[0].toUpperCase() + role.substring(1)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedRoles.add(role);
                  } else {
                    _selectedRoles.remove(role);
                  }
                });
              },
              selectedColor: AppColors.primary.withAlpha(50),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
        TextField(
          controller: _bioController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Bio & Notes',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: AeroCTA(
            label: 'Save Person',
            isLoading: _isLoading,
            onPressed: _savePerson,
          ),
        ),
      ],
    );
  }
}
