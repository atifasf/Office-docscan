    import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// ─── Language Model ───────────────────────────────────────────────────────────

class OcrLanguage {
  final String code;
  final String name;
  final String nativeName;
  final TextRecognitionScript script;

  const OcrLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.script,
  });
}

const ocrLanguages = [
  OcrLanguage(code: 'en', name: 'English',  nativeName: 'English',  script: TextRecognitionScript.latin),
  OcrLanguage(code: 'ur', name: 'Urdu',     nativeName: 'اردو',     script: TextRecognitionScript.latin),
  OcrLanguage(code: 'hi', name: 'Hindi',    nativeName: 'हिन्दी',   script: TextRecognitionScript.latin),
  OcrLanguage(code: 'ar', name: 'Arabic',   nativeName: 'العربية',  script: TextRecognitionScript.latin),
  OcrLanguage(code: 'zh', name: 'Chinese',  nativeName: '中文',      script: TextRecognitionScript.chinese),
  OcrLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語',    script: TextRecognitionScript.japanese),
  OcrLanguage(code: 'ko', name: 'Korean',   nativeName: '한국어',    script: TextRecognitionScript.korean),
  OcrLanguage(code: 'fr', name: 'French',   nativeName: 'Français', script: TextRecognitionScript.latin),
  OcrLanguage(code: 'de', name: 'German',   nativeName: 'Deutsch',  script: TextRecognitionScript.latin),
  OcrLanguage(code: 'es', name: 'Spanish',  nativeName: 'Español',  script: TextRecognitionScript.latin),
];

// ─── State ────────────────────────────────────────────────────────────────────

class OcrState {
  final String extractedText;
  final bool isProcessing;
  final double progress;
  final String? error;
  final List<TextBlock> blocks;
  final OcrLanguage selectedLanguage;

  const OcrState({
    this.extractedText = '',
    this.isProcessing = false,
    this.progress = 0,
    this.error,
    this.blocks = const [],
    this.selectedLanguage = ocrLanguages[0],
  });

  OcrState copyWith({
    String? extractedText,
    bool? isProcessing,
    double? progress,
    String? error,
    List<TextBlock>? blocks,
    OcrLanguage? selectedLanguage,
  }) {
    return OcrState(
      extractedText:    extractedText    ?? this.extractedText,
      isProcessing:     isProcessing     ?? this.isProcessing,
      progress:         progress         ?? this.progress,
      error:            error,
      blocks:           blocks           ?? this.blocks,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }

  bool get hasText   => extractedText.trim().isNotEmpty;
  int  get wordCount => extractedText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  int  get lineCount => extractedText.split('\n').where((l) => l.trim().isNotEmpty).length;
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class OcrNotifier extends StateNotifier<OcrState> {
  OcrNotifier() : super(const OcrState());

  void setLanguage(OcrLanguage lang) {
    state = state.copyWith(selectedLanguage: lang);
  }

  Future<String> recognizeText(File imageFile) async {
    state = state.copyWith(isProcessing: true, progress: 0.1, error: null);

    try {
      final inputImage = InputImage.fromFile(imageFile);
      state = state.copyWith(progress: 0.4);

      final recognizer = TextRecognizer(script: state.selectedLanguage.script);
      final recognized = await recognizer.processImage(inputImage);
      await recognizer.close();

      state = state.copyWith(progress: 0.8);

      state = state.copyWith(
        extractedText: recognized.text,
        blocks:        recognized.blocks,
        isProcessing:  false,
        progress:      1.0,
      );

      return recognized.text;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'OCR failed: ${e.toString()}',
        progress: 0,
      );
      return '';
    }
  }

  void clearText() {
    state = state.copyWith(extractedText: '', blocks: []);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>(
  (_) => OcrNotifier(),
);

final selectedOcrLanguageProvider = Provider<OcrLanguage>(
  (ref) => ref.watch(ocrProvider).selectedLanguage,
);
