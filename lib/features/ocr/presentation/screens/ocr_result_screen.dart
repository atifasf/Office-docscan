import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/ocr_provider.dart';

class OcrResultScreen extends ConsumerStatefulWidget {
  const OcrResultScreen({
    super.key,
    required this.text,
    required this.title,
    this.imageFile,
  });
  final String text;
  final String title;
  final File? imageFile;

  @override
  ConsumerState<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends ConsumerState<OcrResultScreen> {
  late final TextEditingController _ctrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ocrState = ref.watch(ocrProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Extracted Text'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(
              _isEditing ? Icons.done_rounded : Icons.edit_outlined,
              color: _isEditing ? AppTheme.successGreen : AppTheme.textPrimary,
            ),
          ),
          IconButton(onPressed: _copyText, icon: const Icon(Icons.copy_rounded)),
          IconButton(onPressed: _shareText, icon: const Icon(Icons.share_rounded)),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.surfaceCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('OCR Language', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const Gap(8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ocrLanguages.map((lang) {
                      final isSelected = ocrState.selectedLanguage.code == lang.code;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () async {
                            ref.read(ocrProvider.notifier).setLanguage(lang);
                            if (widget.imageFile != null) {
                              final text = await ref.read(ocrProvider.notifier)
                                  .recognizeText(widget.imageFile!);
                              _ctrl.text = text;
                              setState(() {});
                            }
                          },
                          child: AnimatedContainer(
                            duration: 200.ms,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryBlue : AppTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryBlue : AppTheme.borderColor,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  lang.nativeName,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  lang.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white70 : AppTheme.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.surfaceSheet,
            child: Row(
              children: [
                _StatBadge(icon: Icons.text_fields_rounded, label: '${_wordCount()} words', color: AppTheme.accentCyan),
                const Gap(12),
                _StatBadge(icon: Icons.format_list_numbered_rounded, label: '${_lineCount()} lines', color: AppTheme.primaryBlue),
                const Gap(12),
                _StatBadge(icon: Icons.abc_rounded, label: '${_ctrl.text.length} chars', color: AppTheme.accentEmerald),
                if (ocrState.isProcessing) ...[
                  const Gap(12),
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentCyan)),
                  const Gap(6),
                  const Text('Re-scanning...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: _isEditing
                    ? TextField(
                        controller: _ctrl,
                        maxLines: null,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.7),
                        decoration: const InputDecoration.collapsed(hintText: 'Text here...'),
                        onChanged: (_) => setState(() {}),
                      )
                    : SelectableText(
                        _ctrl.text.isEmpty ? 'No text extracted.' : _ctrl.text,
                        style: TextStyle(
                          color: _ctrl.text.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary,
                          fontSize: 14, height: 1.7,
                        ),
                      ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.03, end: 0),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceCard,
              border: Border(top: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyText,
                    icon: const Icon(Icons.copy_all_rounded, size: 18),
                    label: const Text('Copy All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.borderColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareText,
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: _ctrl.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
          Gap(8), Text('Copied!'),
        ]),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _shareText() async {
    await Share.share(_ctrl.text, subject: widget.title);
  }

  int _wordCount() => _ctrl.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  int _lineCount() => _ctrl.text.split('\n').where((l) => l.trim().isNotEmpty).length;
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.icon, required this.label, required this.color});
  final IconData icon; final String label; final Color color;

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: color, size: 14),
    const Gap(4),
    Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
  ]);
}
