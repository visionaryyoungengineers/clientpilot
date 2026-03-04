import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingWizard extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingWizard({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends ConsumerState<OnboardingWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 5;

  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _businessType = 'Consulting'; // Default

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleFinish() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save collected data
    if (_nameCtrl.text.trim().isNotEmpty) {
      await prefs.setString('profile_name', _nameCtrl.text.trim());
    }
    if (_companyCtrl.text.trim().isNotEmpty) {
      await prefs.setString('profile_company', _companyCtrl.text.trim());
    }
    if (_phoneCtrl.text.trim().isNotEmpty) {
      await prefs.setString('profile_phone', _phoneCtrl.text.trim());
    }
    await prefs.setString('profile_business_type', _businessType);
    
    // Mark as complete and redirect
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Container(
              width: double.infinity,
              height: 4,
              color: AppColors.secondary,
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * progress,
                height: 4,
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientHero,
                ),
              ),
            ),
            
            // Step Indicators
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalSteps, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8,
                    width: _currentStep == index ? 32 : 8,
                    decoration: BoxDecoration(
                      gradient: _currentStep == index ? AppColors.gradientHero : null,
                      color: _currentStep > index 
                          ? AppColors.primary.withAlpha(100)
                          : (_currentStep == index ? null : AppColors.muted),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Managed by buttons
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  _buildWelcomeStep(),
                  _buildProfileStep(),
                  _buildCompanyStep(),
                  _buildBusinessTypeStep(),
                  _buildFinalStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepWrap({required String title, required String subtitle, required Widget child}) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(subtitle, style: TextStyle(color: AppColors.mutedForeground, fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 48),
                child,
                const Spacer(),
                const SizedBox(height: 48),
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(child: OutlinedButton(onPressed: _back, child: const Text('Back')))
                    else const Spacer(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _currentStep == _totalSteps - 1 ? _handleFinish : _next,
                        child: Text(_currentStep == _totalSteps - 1 ? 'Get Started' : 'Continue'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeStep() {
    return _buildStepWrap(
      title: 'Welcome to ClientPilot',
      subtitle: 'Your intelligent AI business co-pilot. Let\'s get your workspace set up in just a few steps.',
      child: Column(
        children: [
          Icon(Icons.rocket_launch_rounded, size: 80, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildProfileStep() {
    final theme = Theme.of(context);
    return _buildStepWrap(
      title: 'About You',
      subtitle: 'What should we call you?',
      child: TextField(
        controller: _nameCtrl,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: 'Your Name',
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.person_outline),
        ),
      ),
    );
  }

  Widget _buildCompanyStep() {
    final theme = Theme.of(context);
    return _buildStepWrap(
      title: 'Your Details',
      subtitle: 'Tell us a bit about your organization.',
      child: Column(
        children: [
          TextField(
            controller: _companyCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Company Name',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.phone),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessTypeStep() {
    final theme = Theme.of(context);
    return _buildStepWrap(
      title: 'Business Type',
      subtitle: 'What industry are you in? ClientPilot customizes AI insights based on this.',
      child: DropdownButtonFormField<String>(
        value: _businessType,
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: ['Consulting', 'Real Estate', 'Freelance', 'Agency', 'Sales', 'Other']
            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
            .toList(),
        onChanged: (val) {
          if (val != null) setState(() => _businessType = val);
        },
      ),
    );
  }

  Widget _buildFinalStep() {
    return _buildStepWrap(
      title: 'All Set!',
      subtitle: 'Your workspace is ready. You can always upload a profile photo or company logo later from the Profile tab.',
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade400),
        ],
      ),
    );
  }
}
