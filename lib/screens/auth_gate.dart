import 'package:flutter/material.dart';
import 'package:impactguide/screens/onboarding_screen.dart';
import 'package:impactguide/services/supabase_auth_service.dart';
import 'package:impactguide/widgets/app_tab_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SupabaseAuthService.instance.isReady) {
      return const _SupabaseNotConfiguredScreen();
    }
    return StreamBuilder(
      stream: SupabaseAuthService.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user != null) return const ImpactGuideTabScaffold();
        return const OnboardingFlow();
      },
    );
  }
}

class _SupabaseNotConfiguredScreen extends StatelessWidget {
  const _SupabaseNotConfiguredScreen();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.cloud_off_outlined, size: 44, color: cs.primary),
                  const SizedBox(height: 12),
                  Text('Supabase isn\'t initialized', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    'Your app is connected to Supabase in Dreamflow, but runtime credentials were not provided to this preview session (often after a web hard refresh).',
                    style: tt.bodyMedium?.copyWith(height: 1.5, color: cs.onSurface.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.onSurface.withValues(alpha: 0.08)),
                    ),
                    child: Text(
                      'Fix: Open the Supabase module → complete Project Setup (if needed) → click “Generate Client Code”.\n\nIf you already did, try Hot Restart.',
                      style: tt.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () {
                      // No in-app action here; Dreamflow manages the integration.
                    },
                    icon: Icon(Icons.settings_suggest_outlined, color: cs.onPrimary),
                    label: const Text('Open Supabase module (left sidebar)'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingFlow()));
                    },
                    icon: const Icon(Icons.shield_outlined),
                    label: const Text('Continue in guest mode'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
