import 'package:flutter/material.dart';
import './case_management_screen.dart';
import './education_screen.dart';
import './emergency_response_screen.dart';
import './medical_tracking_screen.dart';
import '../services/identity_service.dart';
import './profile_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Win With CASEY'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              // Debug trace: detect which path triggers navigation
              debugPrint('[HOME] Person icon tapped → navigating to ProfileScreen');
              try {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ProfileScreen()))
                    .then((_) => debugPrint('[HOME] Returned from ProfileScreen'));
              } catch (e, st) {
                debugPrint('[HOME] Navigation to ProfileScreen failed: $e');
                debugPrint(st.toString());
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: _ProfilePromptBanner(),
            ),
            // Put the image section at the top
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Backdrop to avoid white flashes and keep brand tone
                  ColoredBox(color: theme.colorScheme.surface),
                  // Full image contained within the available space.
                  Center(
                    child: Image.asset(
                      'assets/images/app-back.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Move the four cards to the bottom
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const _HomeQuickNavGrid(),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile completion prompt banner
class _ProfilePromptBanner extends StatefulWidget {
  const _ProfilePromptBanner();

  @override
  State<_ProfilePromptBanner> createState() => _ProfilePromptBannerState();
}

class _ProfilePromptBannerState extends State<_ProfilePromptBanner> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final id = IdentityService.instance;
    if (id.isProfileComplete || _hidden || id.profileNudgeDismissed) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: const Offset(0, 0),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: scheme.primary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Complete your profile', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('Add your name, email, and phone so we can contact you.'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                debugPrint('[HOME] Profile banner Update tapped');
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ProfileScreen()))
                    .then((_) {
                  debugPrint('[HOME] Returned from ProfileScreen via banner');
                  if (mounted) setState(() {});
                });
              },
              icon: const Icon(Icons.edit),
              label: const Text('Update'),
            ),
            IconButton(
              tooltip: 'Dismiss',
              icon: const Icon(Icons.close),
              onPressed: () async {
                debugPrint('[HOME] Profile banner dismissed');
                setState(() => _hidden = true);
                await IdentityService.instance.setProfileNudgeDismissed(true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeQuickNavGrid extends StatelessWidget {
  const _HomeQuickNavGrid();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final red = scheme.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Two columns grid with consistent height
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 4 / 3,
          children: [
            _HomeNavCard(
              title: 'In an Accident?',
              icon: Icons.warning_amber,
              background: red,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EmergencyResponseScreen()),
              ),
            ),
            _HomeNavCard(
              title: 'Medical',
              icon: Icons.medical_services,
              background: red,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MedicalTrackingScreen()),
              ),
            ),
            _HomeNavCard(
              title: 'My Case',
              icon: Icons.work,
              background: red,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CaseManagementScreen()),
              ),
            ),
            _HomeNavCard(
              title: 'Education',
              icon: Icons.school,
              background: red,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EducationScreen()),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HomeNavCard extends StatelessWidget {
  const _HomeNavCard({
    required this.title,
    required this.icon,
    required this.background,
    this.foreground,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color background;
  final Color? foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = foreground ?? Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                background,
                Color.alphaBlend(Colors.black.withValues(alpha: 0.08), background),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconBadge(icon: icon, color: textColor),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withValues(alpha: 0.15);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 22),
    );
  }
}
