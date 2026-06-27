import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/scanner_provider.dart';
import '../../../ocr/providers/ocr_provider.dart';
import '../../../pdf/providers/pdf_provider.dart';
import 'ocr_result_screen.dart';

class ScanPreviewScreen extends ConsumerStatefulWidget {
  const ScanPreviewScreen({super.key, required this.imageFile});
  final File imageFile;

  @override
  ConsumerState<ScanPreviewScreen> createState() => _ScanPreviewScreenState();
}

class _ScanPreviewScreenState extends ConsumerState<ScanPreviewScreen> {
  final _titleCtrl = TextEditingController();
  bool _saved = false;
  String? _savedScanId;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = 'Scan ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ocrState = ref.watch(ocrProvider);
    final pdfState = ref.watch(pdfProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [
          if (!_saved)
            TextButton.icon(
              onPressed: _saveScan,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.accentEmerald),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image Preview ───────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                widget.imageFile,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

            const Gap(20),

            // ─── Title field ─────────────────────────────────────────────
            _SectionLabel('Document Title'),
            const Gap(8),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceCard,
                hintText: 'Enter document name...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue),
                ),
                prefixIcon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 18),
              ),
            ),

            const Gap(24),

            // ─── Action Buttons ──────────────────────────────────────────
            _SectionLabel('Actions'),
            const Gap(12),

            Row(
              children: [
                // OCR Button
                Expanded(
                  child: _ActionCard(
                    icon: Icons.text_snippet_outlined,
                    label: 'Extract Text',
                    sublabel: 'AI OCR',
                    color: AppTheme.accentCyan,
                    isLoading: ocrState.isProcessing,
                    onTap: _runOcr,
                  ),
                ),
                const Gap(12),
                // PDF Button
                Expanded(
                  child: _ActionCard(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'Export PDF',
                    sublabel: 'A4 format',
                    color: AppTheme.errorRed,
                    isLoading: pdfState.isGenerating,
                    onTap: _exportPdf,
                  ),
                ),
              ],
            ),

            const Gap(12),

            // OCR Text preview
            if (ocrState.hasText) ...[
              const Gap(4),
              _OcrPreviewCard(
                text: ocrState.extractedText,
                wordCount: ocrState.wordCount,
                lineCount: ocrState.lineCount,
                onViewFull: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => OcrResultScreen(
                    text: ocrState.extractedText,
                    title: _titleCtrl.text,
                  )),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ],

            // PDF progress
            if (pdfState.isGenerating) ...[
              const Gap(16),
              _ProgressCard(
                label: 'Generating PDF...',
                progress: pdfState.progress,
              ).animate().fadeIn(duration: 300.ms),
            ],

            // Success state
            if (pdfState.lastPdfPath != null && !pdfState.isGenerating) ...[
              const Gap(16),
              _PdfSuccessCard(
                pdfPath: pdfState.lastPdfPath!,
                onOpen: () => ref.read(pdfProvider.notifier)
                    .openPdf(pdfState.lastPdfPath!),
                onShare: () => ref.read(pdfProvider.notifier)
                    .sharePdf(pdfState.lastPdfPath!, _titleCtrl.text),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            ],

            const Gap(32),
          ],
        ),
      ),
    );
  }

  Future<void> _saveScan() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack('Please enter a title');
      return;
    }
    final ocrText = ref.read(ocrProvider).extractedText;
    final scan = await ref.read(scannerProvider.notifier).saveScan(
      imageFile: widget.imageFile,
      title: _titleCtrl.text.trim(),
      ocrText: ocrText,
    );
    if (scan != null && mounted) {
      setState(() {
        _saved = true;
        _savedScanId = scan.id;
      });
      _showSnack('Scan saved successfully!', isSuccess: true);
    }
  }

  Future<void> _runOcr() async {
    if (!_saved) await _saveScan();
    await ref.read(ocrProvider.notifier).recognizeText(widget.imageFile);
    final text = ref.read(ocrProvider).extractedText;
    if (text.isNotEmpty && _savedScanId != null) {
      // Update scan with OCR text
      await ref.read(scannerProvider.notifier).loadScans();
    }
    if (!ref.read(ocrProvider).hasText && mounted) {
      _showSnack('No text found in image');
    }
  }

  Future<void> _exportPdf() async {
    if (!_saved) await _saveScan();
    final scans = ref.read(scannerProvider).scans;
    if (scans.isEmpty) return;

    final scan = scans.firstWhere((s) => s.imagePath == widget.imageFile.path,
        orElse: () => scans.first);

    await ref.read(pdfProvider.notifier).generateFromScan(
      scan,
      includeOcrText: ref.read(ocrProvider).hasText,
    );
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: Colors.white, size: 18,
          ),
          const Gap(8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: isSuccess ? AppTheme.successGreen : AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    color: color, strokeWidth: 2.5,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 26),
                  const Gap(8),
                  Text(label, style: TextStyle(
                    color: color, fontSize: 14, fontWeight: FontWeight.w700,
                  )),
                  Text(sublabel, style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11,
                  )),
                ],
              ),
      ),
    );
  }
}

class _OcrPreviewCard extends StatelessWidget {
  const _OcrPreviewCard({
    required this.text,
    required this.wordCount,
    required this.lineCount,
    required this.onViewFull,
  });
  final String text;
  final int wordCount;
  final int lineCount;
  final VoidCallback onViewFull;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.text_snippet_rounded, color: AppTheme.accentCyan, size: 18),
              const Gap(8),
              const Text('Extracted Text',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              _Chip('$wordCount words'),
              const Gap(6),
              _Chip('$lineCount lines'),
            ],
          ),
          const Gap(10),
          Text(
            text.length > 200 ? '${text.substring(0, 200)}...' : text,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
          ),
          const Gap(10),
          GestureDetector(
            onTap: onViewFull,
            child: const Text(
              'View Full Text →',
              style: TextStyle(
                color: AppTheme.accentCyan,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppTheme.accentCyan.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: const TextStyle(color: AppTheme.accentCyan, fontSize: 11)),
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.label, required this.progress});
  final String label;
  final double progress;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.borderColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
        const Gap(10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.borderColor,
            valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
            minHeight: 6,
          ),
        ),
        const Gap(6),
        Text('${(progress * 100).toInt()}%',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    ),
  );
}

class _PdfSuccessCard extends StatelessWidget {
  const _PdfSuccessCard({
    required this.pdfPath,
    required this.onOpen,
    required this.onShare,
  });
  final String pdfPath;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final fileName = pdfPath.split('/').last;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 20),
            const Gap(8),
            const Text('PDF Ready', style: TextStyle(
              color: AppTheme.successGreen, fontWeight: FontWeight.w700, fontSize: 15,
            )),
          ]),
          const Gap(8),
          Text(fileName, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const Gap(14),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Open'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.borderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
