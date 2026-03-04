import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../widgets/aero_card.dart';

import 'dart:convert';
import 'package:flutter/services.dart';

class GovtScheme {
  final String name, ministry, description, eligibility, link;
  final List<String> businessTypes;
  const GovtScheme({required this.name, required this.ministry, required this.description, required this.eligibility, required this.link, required this.businessTypes});
  
  factory GovtScheme.fromJson(Map<String, dynamic> json) {
    return GovtScheme(
      name: json['name'],
      ministry: json['ministry'],
      description: json['description'],
      eligibility: json['eligibility'],
      link: json['link'],
      businessTypes: List<String>.from(json['businessTypes'] ?? []),
    );
  }
}

const _businessTypes = ['All', 'MSME', 'Startup', 'Tech', 'Sole Proprietor', 'Partnership', 'Manufacturing', 'Education'];

class GovernmentSchemesScreen extends StatefulWidget {
  const GovernmentSchemesScreen({super.key});
  @override State<GovernmentSchemesScreen> createState() => _GovernmentSchemesScreenState();
}

class _GovernmentSchemesScreenState extends State<GovernmentSchemesScreen> {
  String _selectedType = 'All';
  final _searchCtrl = TextEditingController();
  String _query = '';
  List<GovtScheme> _schemes = [];
  bool _isLoading = true;
  
  @override 
  void initState() {
    super.initState();
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/government_schemes.json');
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      if (mounted) {
        setState(() {
          _schemes = jsonList.map((e) => GovtScheme.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<GovtScheme> get _filtered => _schemes.where((s) {
    final q = _query.toLowerCase();
    final matchesSearch = q.isEmpty || s.name.toLowerCase().contains(q) || s.description.toLowerCase().contains(q) || s.ministry.toLowerCase().contains(q);
    final matchesType = _selectedType == 'All' || s.businessTypes.contains(_selectedType);
    return matchesSearch && matchesType;
  }).toList();

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Header
          AeroCard(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1e3a5f), Color(0xFF0284c7)]), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('🏛', style: TextStyle(fontSize: 22)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Government Schemes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${_schemes.length} schemes available for Indian businesses', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140))),
              ])),
            ]),
          ),
          const SizedBox(height: 12),

          // Search
          Container(
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 12, offset: const Offset(0, 4))]),
            child: TextField(controller: _searchCtrl, onChanged: (v) => setState(() => _query = v), decoration: InputDecoration(
              hintText: 'Search schemes...', prefixIcon: Icon(LucideIcons.search, size: 18, color: theme.colorScheme.onSurface.withAlpha(100)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16))),
          ),
          const SizedBox(height: 10),

          // Filter chips
          SizedBox(height: 38, child: ListView(scrollDirection: Axis.horizontal, children: _businessTypes.map((t) {
            final sel = _selectedType == t;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? theme.colorScheme.primary.withAlpha(25) : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: sel ? Border.all(color: theme.colorScheme.primary.withAlpha(100), width: 1.5) : null,
                ),
                child: Text(t, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: sel ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(150))),
              ),
            );
          }).toList())),
          const SizedBox(height: 16),

          if (_isLoading)
             const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: CircularProgressIndicator()))
          else if (_filtered.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text('No schemes found for this category.')))
          else
            ..._filtered.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SchemeCard(scheme: s),
            )),
        ],
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final GovtScheme scheme;
  const _SchemeCard({required this.scheme});

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AeroCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(scheme.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFF0284c7).withAlpha(20), borderRadius: BorderRadius.circular(10)),
            child: Text(scheme.ministry.split(' ').take(2).join(' '), style: const TextStyle(fontSize: 10, color: Color(0xFF0284c7), fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 6),
        Text(scheme.description, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(160))),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(LucideIcons.circleCheck, size: 14, color: const Color(0xFF16A34A)),
          const SizedBox(width: 6),
          Expanded(child: Text(scheme.eligibility, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140)))),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 4, children: scheme.businessTypes.map((t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(15), borderRadius: BorderRadius.circular(10)),
          child: Text(t, style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
        )).toList()),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            // Open external browser — using simple alertDialog as placeholder since url_launcher not added
            showDialog(context: context, builder: (_) => AlertDialog(
              title: const Text('Open Link'),
              content: Text('This would open:\n${scheme.link}'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
            ));
          },
          child: Row(children: [
            Icon(LucideIcons.externalLink, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text('Learn More & Apply', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
          ]),
        ),
      ]),
    );
  }
}
