import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../scanner/presentation/screens/scan_list_screen.dart';
import '../../../pdf/presentation/screens/pdf_list_screen.dart';
import '../../../scanner/presentation/screens/camera_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    ScanListScreen(),
    PdfListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: IndexedStack(index: _currentIndex, children: _pages),

      // ─── FAB: Scan ───────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CameraScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.scannerGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.document_scanner_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Scan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().scale(
        delay: 300.ms, duration: 400.ms,
        curve: Curves.elasticOut,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ─── Bottom Nav ──────────────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceCard,
        border: Border(top: BorderSide(color: AppTheme.borderColor, width: 0.8)),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.photo_library_outlined,
              activeIcon: Icons.photo_library_rounded,
              label: 'Scans',
              active: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            const Spacer(),
            _NavItem(
              icon: Icons.picture_as_pdf_outlined,
              activeIcon: Icons.picture_as_pdf_rounded,
              label: 'PDFs',
              active: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 70),
            _NavItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              label: 'Settings',
              active: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? activeIcon : icon,
              color: active ? AppTheme.primaryBlue : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppTheme.primaryBlue : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
