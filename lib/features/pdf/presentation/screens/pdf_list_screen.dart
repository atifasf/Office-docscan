import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/pdf_provider.dart';

class PdfListScreen extends ConsumerWidget {
  const PdfListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppTheme.surfaceDark,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: const Text(
                'My PDFs',
                style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A0A2E), AppTheme.surfaceDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          if (state.pdfs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded,
                          color: AppTheme.errorRed, size: 40),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    const Gap(20),
                    const Text('No PDFs yet',
                        style: TextStyle(color: AppTheme.textPrimary,
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const Gap(8),
                    const Text('Export a scan as PDF to see it here',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final pdf = state.pdfs[i];
                    return _PdfCard(
                      pdf: pdf,
                      index: i,
                      onOpen: () => ref.read(pdfProvider.notifier)
                          .openPdf(pdf['pdfPath'] as String),
                      onShare: () => ref.read(pdfProvider.notifier)
                          .sharePdf(pdf['pdfPath'] as String, pdf['title'] as String),
                      onPrint: () => ref.read(pdfProvider.notifier)
                          .printPdf(pdf['pdfPath'] as String),
                      onDelete: () => ref.read(pdfProvider.notifier)
                          .deletePdf(pdf['id'] as String, pdf['pdfPath'] as String),
                    );
                  },
                  childCount: state.pdfs.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PdfCard extends StatelessWidget {
  const _PdfCard({
    required this.pdf,
    required this.index,
    required this.onOpen,
    required this.onShare,
    required this.onPrint,
    required this.onDelete,
  });
  final Map<String, dynamic> pdf;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title     = pdf['title'] as String;
    final pages     = pdf['pageCount'] as int? ?? 1;
    final bytes     = pdf['sizeBytes'] as int? ?? 0;
    final createdAt = DateTime.tryParse(pdf['createdAt'] as String? ?? '');

    final sizeStr = bytes > 1024 * 1024
        ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(bytes / 1024).toStringAsFixed(0)} KB';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // PDF Icon
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded,
                      color: AppTheme.errorRed, size: 24),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14, fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(4),
                      Row(children: [
                        _InfoChip('$pages page${pages > 1 ? 's' : ''}'),
                        const Gap(6),
                        _InfoChip(sizeStr),
                        if (createdAt != null) ...[
                          const Gap(6),
                          _InfoChip(DateFormat('dd MMM').format(createdAt)),
                        ],
                      ]),
                    ],
                  ),
                ),
                // More options
                PopupMenuButton<String>(
                  color: AppTheme.surfaceSheet,
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppTheme.textSecondary),
                  onSelected: (val) {
                    switch (val) {
                      case 'open':   onOpen();   break;
                      case 'share':  onShare();  break;
                      case 'print':  onPrint();  break;
                      case 'delete': onDelete(); break;
                    }
                  },
                  itemBuilder: (_) => [
                    _menuItem('open',   Icons.open_in_new_rounded, 'Open'),
                    _menuItem('share',  Icons.share_rounded,        'Share'),
                    _menuItem('print',  Icons.print_rounded,        'Print'),
                    _menuItem('delete', Icons.delete_outline_rounded, 'Delete',
                        color: AppTheme.errorRed),
                  ],
                ),
              ],
            ),

            const Gap(12),

            // Quick action row
            Row(children: [
              _QuickButton(
                icon: Icons.open_in_new_rounded,
                label: 'Open',
                onTap: onOpen,
              ),
              const Gap(8),
              _QuickButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: onShare,
                isPrimary: true,
              ),
            ]),
          ],
        ),
      ).animate(delay: Duration(milliseconds: index * 60))
       .fadeIn(duration: 300.ms)
       .slideY(begin: 0.04, end: 0),
    );
  }

  PopupMenuItem<String> _menuItem(
    String value, IconData icon, String label, {Color? color}) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, color: color ?? AppTheme.textPrimary, size: 18),
        const Gap(10),
        Text(label, style: TextStyle(color: color ?? AppTheme.textPrimary)),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: AppTheme.borderColor,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(label,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
  );
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.primaryBlue
              : AppTheme.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: isPrimary
              ? null
              : Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16,
              color: isPrimary ? Colors.white : AppTheme.primaryBlue),
            const Gap(6),
            Text(label,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
