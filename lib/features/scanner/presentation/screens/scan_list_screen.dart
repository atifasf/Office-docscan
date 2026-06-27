import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/scanner_provider.dart';
import '../../data/scan_model.dart';
import 'scan_preview_screen.dart';

class ScanListScreen extends ConsumerWidget {
  const ScanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scannerProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: CustomScrollView(
        slivers: [
          // ─── Header ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppTheme.surfaceDark,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: const Text(
                'My Scans',
                style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E1B4B), AppTheme.surfaceDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // ─── Search ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                onChanged: ref.read(scannerProvider.notifier).setSearchQuery,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search scans and text...',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  filled: true,
                  fillColor: AppTheme.surfaceCard,
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
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.textSecondary, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ),

          // ─── Content ─────────────────────────────────────────────────
          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
            )
          else if (state.filteredScans.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(
                hasSearch: state.searchQuery.isNotEmpty,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final scan = state.filteredScans[i];
                    return _ScanCard(
                      scan: scan,
                      index: i,
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => ScanPreviewScreen(
                            imageFile: File(scan.imagePath),
                          ),
                        ),
                      ),
                      onFavourite: () => ref.read(scannerProvider.notifier)
                          .toggleFavourite(scan.id),
                      onDelete: () => _confirmDelete(context, ref, scan),
                    );
                  },
                  childCount: state.filteredScans.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context, WidgetRef ref, ScanModel scan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Delete Scan',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Delete "${scan.title}"? This cannot be undone.',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(scannerProvider.notifier).deleteScan(scan.id);
    }
  }
}

// ─── Scan Card ────────────────────────────────────────────────────────────────

class _ScanCard extends StatelessWidget {
  const _ScanCard({
    required this.scan,
    required this.index,
    required this.onTap,
    required this.onFavourite,
    required this.onDelete,
  });
  final ScanModel scan;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onFavourite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor, width: 0.8),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: _Thumbnail(imagePath: scan.imagePath),
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(6),
                      Row(children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 11, color: AppTheme.textSecondary),
                        const Gap(4),
                        Text(
                          DateFormat('dd MMM yyyy').format(scan.createdAt),
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ]),
                      if (scan.ocrText.isNotEmpty) ...[
                        const Gap(6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'OCR',
                            style: TextStyle(
                              color: AppTheme.accentCyan, fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Actions
              Column(
                children: [
                  IconButton(
                    onPressed: onFavourite,
                    icon: Icon(
                      scan.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: scan.isFavorite
                          ? AppTheme.errorRed
                          : AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.textSecondary, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: index * 60))
       .fadeIn(duration: 300.ms)
       .slideX(begin: -0.04, end: 0),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    return SizedBox(
      width: 76,
      height: 90,
      child: file.existsSync()
          ? Image.file(file, fit: BoxFit.cover)
          : Container(
              color: AppTheme.surfaceSheet,
              child: const Icon(Icons.image_outlined,
                  color: AppTheme.textSecondary, size: 28),
            ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearch});
  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasSearch
                  ? Icons.search_off_rounded
                  : Icons.document_scanner_rounded,
              color: AppTheme.primaryBlue,
              size: 40,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const Gap(20),
          Text(
            hasSearch ? 'No results found' : 'No scans yet',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          Text(
            hasSearch
                ? 'Try a different keyword'
                : 'Tap Scan below to start scanning',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
