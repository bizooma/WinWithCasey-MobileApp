import 'package:flutter/material.dart';

import '../widgets/app_tab_shell.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _index = 0;

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ImpactGuideTabScaffold()),
    );
  }

  void _next() {
    if (_index < 3) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
    } else {
      _goHome();
    }
  }

  void _back() {
    if (_index > 0) {
      _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final pages = [
      _OnboardPage(
        icon: Icons.warning_amber_rounded,
        title: 'In an Accident',
        description:
            'Open Emergency to capture photos, your location, and quick notes. Organizes everything into a shareable package for your attorney.',
        accentColor: cs.primary,
      ),
      _OnboardPage(
        icon: Icons.medical_services_rounded,
        title: 'Medical',
        description:
            'Track appointments, medications, symptoms, and recovery progress. Add records to keep your treatment organized and visible.',
        accentColor: cs.tertiary,
      ),
      _OnboardPage(
        icon: Icons.work_rounded,
        title: 'My Case',
        description:
            'Review your case timeline, important details, and documents. Keep everything in one place throughout the process.',
        accentColor: cs.secondary,
      ),
      _OnboardPage(
        icon: Icons.school_rounded,
        title: 'Education',
        description:
            'Short videos and guides explain what to expect, your rights, and how to make the strongest recovery—legally and medically.',
        accentColor: cs.primary,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Text(
                        'Win With CASEY',
                        key: ValueKey(_index),
                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _goHome,
                    child: Text('Skip', style: tt.labelLarge?.copyWith(color: cs.primary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: pages.length,
                itemBuilder: (_, i) => pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _index == 0 ? null : _back,
                    icon: Icon(Icons.chevron_left, color: _index == 0 ? cs.onSurface.withValues(alpha: 0.3) : cs.primary),
                    label: Text(
                      'Back',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: _index == 0 ? cs.onSurface.withValues(alpha: 0.3) : cs.primary,
                          ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(
                      4,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: i == _index ? 18 : 6,
                        decoration: BoxDecoration(
                          color: i == _index ? cs.primary : cs.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _next,
                    icon: Icon(_index == 3 ? Icons.check_rounded : Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onPrimary),
                    label: Text(_index == 3 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [accentColor, cs.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(icon, size: 72, color: cs.onPrimary),
            ),
          ),
          const SizedBox(height: 24),
          Text(title, style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(
            description,
            style: tt.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          _TipBullet(text: _tipFor(title, context)),
          const Spacer(),
        ],
      ),
    );
  }

  static String _tipFor(String title, BuildContext context) {
    switch (title) {
      case 'In an Accident':
        return 'Tip: Use the camera inside the app so photos stay tied to your case.';
      case 'Medical':
        return 'Tip: Log pain levels and meds daily—small details strengthen your claim.';
      case 'My Case':
        return 'Tip: Add notes right after conversations so your timeline stays precise.';
      case 'Education':
      default:
        return 'Tip: Watch the 2‑min “First Week” video to avoid common pitfalls.';
    }
  }
}

class _TipBullet extends StatelessWidget {
  final String text;
  const _TipBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lightbulb, size: 18, color: cs.tertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.8)),
          ),
        ),
      ],
    );
  }
}
