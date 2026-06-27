import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../pdf/presentation/screens/multi_page_pdf_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.surfaceDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── User Profile Card ─────────────────────────────────────
          if (user != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),

          const Gap(20),

          // ─── Features ─────────────────────────────────────────────
          _SectionTitle(title: 'Features'),
          const Gap(8),

          _SettingsTile(
            icon: Icons.layers_rounded,
            color: AppTheme.accentCyan,
            title: 'Multi-Page PDF',
            subtitle: 'Combine multiple scans into one PDF',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MultiPagePdfScreen())),
          ),

          const Gap(20),

          // ─── Account ─────────────────────────────────────────────
          _SectionTitle(title: 'Account'),
          const Gap(8),

          _SettingsTile(
            icon: Icons.person_outline_rounded,
            color: AppTheme.primaryBlue,
            title: 'Profile',
            subtitle: user?.email ?? 'Not logged in',
          ),

          const Gap(8),

          _SettingsTile(
            icon: Icons.logout_rounded,
            color: AppTheme.errorRed,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppTheme.surfaceCard,
                  title: const Text('Logout', style: TextStyle(color: AppTheme.textPrimary)),
                  content: const Text('Are you sure you want to logout?', style: TextStyle(color: AppTheme.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout', style: TextStyle(color: AppTheme.errorRed)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authProvider.notifier).logout();
              }
            },
          ),

          const Gap(20),

          // ─── App info ─────────────────────────────────────────────
          _SectionTitle(title: 'About'),
          const Gap(8),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            color: AppTheme.textSecondary,
            title: 'ScanVerse AI',
            subtitle: 'Version 2.0.0',
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms),
  );
}
