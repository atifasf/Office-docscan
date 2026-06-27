import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/scanner_provider.dart';
import 'scan_preview_screen.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scannerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: const Text(
          'ScanVerse AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // ─── Scan Viewfinder Placeholder ─────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Dark background with scanner animation
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF000000), Color(0xFF0A0E1A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Scanner frame
                        _ScannerFrame()
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(
                              duration: 2.seconds,
                              color: AppTheme.accentCyan.withOpacity(0.3),
                            ),
                        const Gap(24),
                        Text(
                          'Position document within frame',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Processing overlay
                if (scanState.isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppTheme.accentCyan),
                          Gap(16),
                          Text(
                            'Processing scan...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ─── Controls ─────────────────────────────────────────────────
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery
                _ControlButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () => _pickFromGallery(context, ref),
                ),

                // Capture button (main)
                GestureDetector(
                  onTap: () => _capturePhoto(context, ref),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.scannerGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .scale(
                     begin: const Offset(1.0, 1.0),
                     end: const Offset(1.05, 1.05),
                     duration: 1500.ms,
                     curve: Curves.easeInOut,
                   ),
                ),

                // Flash toggle (decorative in this version)
                _ControlButton(
                  icon: Icons.flash_auto_rounded,
                  label: 'Auto',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _capturePhoto(BuildContext context, WidgetRef ref) async {
    final file = await ref.read(scannerProvider.notifier).captureFromCamera();
    if (file != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ScanPreviewScreen(imageFile: file)),
      );
    }
  }

  Future<void> _pickFromGallery(BuildContext context, WidgetRef ref) async {
    final file = await ref.read(scannerProvider.notifier).pickFromGallery();
    if (file != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ScanPreviewScreen(imageFile: file)),
      );
    }
  }
}

// ─── Scanner Frame Widget ────────────────────────────────────────────────────

class _ScannerFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 340,
      child: CustomPaint(painter: _FramePainter()),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentCyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 28.0;
    const r = 8.0;

    // Top-left
    canvas.drawLine(Offset(r, 0), Offset(cornerLen, 0), paint);
    canvas.drawLine(Offset(0, r), Offset(0, cornerLen), paint);
    canvas.drawArc(const Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, 1.57, false, paint);

    // Top-right
    canvas.drawLine(Offset(size.width - cornerLen, 0), Offset(size.width - r, 0), paint);
    canvas.drawLine(Offset(size.width, r), Offset(size.width, cornerLen), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), 4.71, 1.57, false, paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height - cornerLen), Offset(0, size.height - r), paint);
    canvas.drawLine(Offset(r, size.height), Offset(cornerLen, size.height), paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), 1.57, 1.57, false, paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height - cornerLen), Offset(size.width, size.height - r), paint);
    canvas.drawLine(Offset(size.width - cornerLen, size.height), Offset(size.width - r, size.height), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2), 0, 1.57, false, paint);

    // Scan line
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, AppTheme.accentCyan.withOpacity(0.6), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, size.height / 2, size.width, 2));
    canvas.drawLine(
      Offset(8, size.height * 0.5),
      Offset(size.width - 8, size.height * 0.5),
      scanPaint..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Control Button ──────────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const Gap(6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
