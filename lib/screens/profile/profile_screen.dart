import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../services/background_processing_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl    = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _businessType  = 'Tech / Software';
  String? _gender;
  DateTime? _dob;
  double _humourLevel   = 0.5;
  bool   _recordingContext = false;

  String? _profilePhotoPath;
  String? _companyLogoPath;

  static const _businessTypes = [
    'Freelancer', 'Tech / Software', 'Consulting', 'Manufacturing',
    'Retail / E-commerce', 'Healthcare', 'Education', 'Real Estate', 'Other',
  ];
  static const _humourLabels = ['🧊 Serious', '😐 Neutral', '😄 Friendly', '🤣 Humorous'];

  final _recorder  = AudioRecorder();
  final _imgPicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _humourLevel       = prefs.getDouble('profile_humour_level') ?? 0.5;
      _nameCtrl.text     = prefs.getString('profile_name')          ?? '';
      _companyCtrl.text  = prefs.getString('profile_company')       ?? '';
      _phoneCtrl.text    = prefs.getString('profile_phone')         ?? '';
      _locationCtrl.text = prefs.getString('profile_location')      ?? '';
      _businessType      = prefs.getString('profile_business_type') ?? 'Tech / Software';
      _gender            = prefs.getString('profile_gender');
      final dobStr       = prefs.getString('profile_dob');
      if (dobStr != null) _dob = DateTime.tryParse(dobStr);
      _profilePhotoPath  = prefs.getString('profile_photo_path');
      _companyLogoPath   = prefs.getString('company_logo_path');
    });
  }

  Future<void> _saveHumour(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('profile_humour_level', val);
  }

  Future<void> _pickProfilePhoto() async {
    final result = await _imgPicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (result == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_photo_path', result.path);
    setState(() => _profilePhotoPath = result.path);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated ✓')));
  }

  Future<void> _pickCompanyLogo() async {
    final result = await _imgPicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (result == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_logo_path', result.path);
    setState(() => _companyLogoPath = result.path);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Company logo updated ✓')));
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _nameCtrl.text.isNotEmpty
        ? _nameCtrl.text.trim().split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── Avatar + Company Logo header ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Profile photo
              Column(children: [
                GestureDetector(
                  onTap: _pickProfilePhoto,
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: theme.colorScheme.primary,
                      backgroundImage: _profilePhotoPath != null
                          ? FileImage(File(_profilePhotoPath!))
                          : null,
                      child: _profilePhotoPath == null
                          ? Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26))
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.surface, width: 2),
                      ),
                      child: const Icon(LucideIcons.camera, size: 13, color: Colors.white),
                    ),
                  ]),
                ),
                const SizedBox(height: 6),
                Text('Profile Photo', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(140))),
              ]),

              const SizedBox(width: 32),

              // Company logo
              Column(children: [
                GestureDetector(
                  onTap: _pickCompanyLogo,
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surfaceContainerHighest,
                        image: _companyLogoPath != null
                            ? DecorationImage(image: FileImage(File(_companyLogoPath!)), fit: BoxFit.cover)
                            : null,
                        border: Border.all(color: theme.colorScheme.outline.withAlpha(60)),
                      ),
                      child: _companyLogoPath == null
                          ? Center(child: Icon(LucideIcons.building2, size: 28, color: theme.colorScheme.onSurface.withAlpha(120)))
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.surface, width: 2),
                      ),
                      child: const Icon(LucideIcons.camera, size: 13, color: Colors.white),
                    ),
                  ]),
                ),
                const SizedBox(height: 6),
                Text('Company Logo', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(140))),
              ]),
            ],
          ),

          const SizedBox(height: 10),
          Center(child: Column(children: [
            Text(_nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Your Name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_companyCtrl.text.isNotEmpty ? _companyCtrl.text : 'Your Company', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withAlpha(140))),
          ])),
          const SizedBox(height: 24),

          // ── Personal Info (read-only except new fields and location) ───────
          _SectionCard(
            title: 'Personal Info',
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _ProfileField(label: 'Full Name',   icon: LucideIcons.user,     controller: _nameCtrl,    enabled: false),
              _ProfileField(label: 'Company',     icon: LucideIcons.building2, controller: _companyCtrl, enabled: false),
              _ProfileField(label: 'Phone',       icon: LucideIcons.phone,    controller: _phoneCtrl,   enabled: false, keyboard: TextInputType.phone),
              
              const SizedBox(height: 16),
              const Text('Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _locationCtrl,
                onChanged: (v) async => (await SharedPreferences.getInstance()).setString('profile_location', v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(LucideIcons.mapPin, size: 18),
                  hintText: 'City, Country',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Gender', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, children: ['Male', 'Female', 'Other'].map((g) {
                final sel = _gender == g;
                return ChoiceChip(
                  label: Text(g), selected: sel,
                  onSelected: (selected) async {
                    if (selected) {
                      setState(() => _gender = g);
                      (await SharedPreferences.getInstance()).setString('profile_gender', g);
                    }
                  },
                );
              }).toList()),

              const SizedBox(height: 16),
              const Text('Date of Birth', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dob ?? DateTime(1990),
                    firstDate: DateTime(1930),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _dob = date);
                    (await SharedPreferences.getInstance()).setString('profile_dob', date.toIso8601String());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(LucideIcons.calendar, size: 18, color: theme.colorScheme.onSurface.withAlpha(150)),
                    const SizedBox(width: 12),
                    Text(
                      _dob != null ? '${_dob!.day}/${_dob!.month}/${_dob!.year}' : 'Select Date',
                      style: TextStyle(color: _dob != null ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withAlpha(120)),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Business Type ─────────────────────────────────────────────────
          _SectionCard(
            title: 'Business Type',
            child: Wrap(spacing: 8, runSpacing: 8, children: _businessTypes.map((t) {
              final sel = _businessType == t;
              return GestureDetector(
                onTap: () async {
                  setState(() => _businessType = t);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('profile_business_type', t);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? theme.colorScheme.primary.withAlpha(25) : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: sel ? Border.all(color: theme.colorScheme.primary.withAlpha(100)) : null,
                  ),
                  child: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: sel ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(150))),
                ),
              );
            }).toList()),
          ),
          const SizedBox(height: 12),

          // ── Humour Level ──────────────────────────────────────────────────
          _SectionCard(
            title: 'Humour Level',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_humourLabels[(_humourLevel * 3).round().clamp(0, 3)], style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
              Slider(
                value: _humourLevel,
                onChanged: (v) { setState(() => _humourLevel = v); _saveHumour(v); },
                activeColor: theme.colorScheme.primary,
                divisions: 3,
                label: _humourLabels[(_humourLevel * 3).round().clamp(0, 3)],
              ),
              Text('Adjusts copy tone throughout the app.', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(120))),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Business Context (Voice) ───────────────────────────────────────
          _SectionCard(
            title: 'Business Context',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Record a brief note about what your business does, your target audience, and key value propositions.', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onLongPressStart: (_) async {
                    if (!await _recorder.hasPermission()) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mic permission denied')));
                      return;
                    }
                    final dir = await getApplicationDocumentsDirectory();
                    final path = '${dir.path}/business_context_${DateTime.now().millisecondsSinceEpoch}.m4a';
                    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
                    setState(() => _recordingContext = true);
                  },
                  onLongPressEnd: (_) async {
                    setState(() => _recordingContext = false);
                    final path = await _recorder.stop();
                    if (path != null) {
                      ref.read(backgroundProcessingProvider.notifier).enqueueTask('Business Context Update', path, TaskType.businessContext);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio queued for context parsing!')));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: _recordingContext ? Colors.red : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: (_recordingContext ? Colors.red : theme.colorScheme.primary).withAlpha(100), blurRadius: 12, spreadRadius: 4)],
                    ),
                    child: Icon(_recordingContext ? Icons.mic : Icons.mic_none, color: Colors.white, size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(child: Text(_recordingContext ? 'Recording...' : 'Hold to record context',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _recordingContext ? Colors.red : theme.colorScheme.primary))),
              const SizedBox(height: 16),
              Consumer(builder: (context, ref, _) {
                final tasks = ref.watch(backgroundProcessingProvider).where((t) => t.type == TaskType.businessContext).toList();
                if (tasks.isEmpty) return const SizedBox.shrink();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Processing Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...tasks.map((task) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: task.status == TaskStatus.processing
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.audio_file),
                    title: Text(task.title, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(task.status.name, style: const TextStyle(fontSize: 11)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.play_arrow, size: 20), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () => ref.read(backgroundProcessingProvider.notifier).removeTask(task.id)),
                    ]),
                  )),
                ]);
              }),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Subscription ──────────────────────────────────────────────────
          _SectionCard(
            title: 'Subscription',
            child: Row(children: [
              Icon(LucideIcons.zap, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              const Text('Free Plan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Upgrade →')),
            ]),
          ),
          const SizedBox(height: 12),

          Center(child: Text('ClientPilot v1.0.0  •  Made in India 🇮🇳',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(100)))),
        ],
      ),
    );
  }
}

// ─── Reusable components ──────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title; final Widget child; final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: theme.colorScheme.onSurface.withAlpha(120))),
          const Spacer(),
          if (trailing != null) trailing!,
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label; final IconData icon; final TextEditingController controller;
  final bool enabled; final TextInputType? keyboard;
  const _ProfileField({required this.label, required this.icon, required this.controller, this.enabled = true, this.keyboard});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller, enabled: enabled, keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label, prefixIcon: Icon(icon, size: 18), filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(enabled ? 80 : 50),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
