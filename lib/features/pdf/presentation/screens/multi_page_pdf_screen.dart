import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/pdf_provider.dart';

class MultiPagePdfScreen extends ConsumerStatefulWidget {
  const MultiPagePdfScreen({super.key});

  @override
  ConsumerState<MultiPagePdfScreen> createState() => _MultiPagePdfScreenState();
}

class _MultiPagePdfScreenState extends ConsumerState<MultiPagePdfScreen> {
  final List<File> _pages = [];
  final _titleCtrl = TextEditingController(text: 'My Document');
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pdfState = ref.watch(pdfProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Multi-Page PDF'),
        actions: [
          if (_pages.isNotEmpty)
            TextButton.icon(
              onPressed: pdfState.isGenerating ? null : _generatePdf,
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('Generate'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.accentCyan),
            ),
        ],
      ),
      body: Column(
        children: [
          // Title input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'PDF Title',
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.title_rounded, color: AppTheme.textSecondary, size: 20),
                filled: true,
                fillColor: AppTheme.surfaceCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue)),
              ),
            ),
          ),

          // Page count info
          if (_pages.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.layers_rounded, color: AppTheme.accentCyan, size: 18),
                  const Gap(8),
                  Text('${_pages.length} page${_pages.length > 1 ? 's' : ''} added', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _pages.clear()),
                    child: const Text('Clear All', style: TextStyle(color: AppTheme.errorRed, fontSize: 12)),
                  ),
                ],
              ),
            ).animate().fadeIn(),

          // Progress bar
          if (pdfState.isGenerating)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Generating PDF...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const Gap(6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pdfState.progress,
                      backgroundColor: AppTheme.borderColor,
                      color: AppTheme.primaryBlue,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

          // Pages grid
          Expanded(
            child: _pages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.textSecondary, size: 64),
                        const Gap(16),
                        const Text('Add pages to your PDF', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                        const Gap(8),
                        const Text('Tap + to add from camera or gallery', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ).animate().fadeIn(),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: _pages.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _pages.removeAt(oldIndex);
                        _pages.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      return _PageTile(
                        key: ValueKey(_pages[index].path),
                        file: _pages[index],
                        pageNumber: index + 1,
                        onRemove: () => setState(() => _pages.removeAt(index)),
                      );
                    },
                  ),
          ),
        ],
      ),

      // FAB - Add page
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPageOptions,
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Page', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAddPageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2))),
            const Gap(16),
            const Text('Add Page', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            const Gap(20),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.accentCyan),
              title: const Text('Camera', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () async { Navigator.pop(context); await _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primaryBlue),
              title: const Text('Gallery', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () async { Navigator.pop(context); await _pickImage(ImageSource.gallery); },
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 90);
    if (xFile != null) setState(() => _pages.add(File(xFile.path)));
  }

  Future<void> _generatePdf() async {
    if (_pages.isEmpty) return;
    final title = _titleCtrl.text.trim().isEmpty ? 'My Document' : _titleCtrl.text.trim();
    final path = await ref.read(pdfProvider.notifier).generateMultiPage(_pages, title);
    if (mounted && path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 16), Gap(8), Text('PDF created!'),
          ]),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => ref.read(pdfProvider.notifier).openPdf(path),
          ),
        ),
      );
    }
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile({super.key, required this.file, required this.pageNumber, required this.onRemove});
  final File file;
  final int pageNumber;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            child: Image.file(file, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Page $pageNumber', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                Text(file.path.split('/').last, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 20),
          ),
          const Icon(Icons.drag_handle_rounded, color: AppTheme.textSecondary),
          const Gap(8),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}
