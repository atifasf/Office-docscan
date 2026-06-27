import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/database_helper.dart';
import '../data/scan_model.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class ScannerState {
  final List<ScanModel> scans;
  final bool isLoading;
  final bool isProcessing;
  final String? error;
  final File? capturedImage;
  final String searchQuery;

  const ScannerState({
    this.scans = const [],
    this.isLoading = false,
    this.isProcessing = false,
    this.error,
    this.capturedImage,
    this.searchQuery = '',
  });

  ScannerState copyWith({
    List<ScanModel>? scans,
    bool? isLoading,
    bool? isProcessing,
    String? error,
    File? capturedImage,
    String? searchQuery,
  }) {
    return ScannerState(
      scans:         scans         ?? this.scans,
      isLoading:     isLoading     ?? this.isLoading,
      isProcessing:  isProcessing  ?? this.isProcessing,
      error:         error,
      capturedImage: capturedImage ?? this.capturedImage,
      searchQuery:   searchQuery   ?? this.searchQuery,
    );
  }

  List<ScanModel> get filteredScans {
    if (searchQuery.isEmpty) return scans;
    final q = searchQuery.toLowerCase();
    return scans.where((s) =>
      s.title.toLowerCase().contains(q) ||
      s.ocrText.toLowerCase().contains(q)
    ).toList();
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier() : super(const ScannerState()) {
    loadScans();
  }

  final _db     = DatabaseHelper.instance;
  final _picker = ImagePicker();
  final _uuid   = const Uuid();

  // Load all scans from DB
  Future<void> loadScans() async {
    state = state.copyWith(isLoading: true);
    try {
      final maps  = await _db.getAllScans();
      final scans = maps.map(ScanModel.fromMap).toList();
      state = state.copyWith(scans: scans, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Capture from camera
  Future<File?> captureFromCamera() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (xFile == null) return null;
    final file = File(xFile.path);
    state = state.copyWith(capturedImage: file);
    return file;
  }

  // Pick from gallery
  Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xFile == null) return null;
    final file = File(xFile.path);
    state = state.copyWith(capturedImage: file);
    return file;
  }

  // Save scan to DB
  Future<ScanModel?> saveScan({
    required File imageFile,
    required String title,
    String ocrText = '',
  }) async {
    state = state.copyWith(isProcessing: true);
    try {
      final now  = DateTime.now();
      final scan = ScanModel(
        id:        _uuid.v4(),
        title:     title,
        imagePath: imageFile.path,
        ocrText:   ocrText,
        createdAt: now,
        updatedAt: now,
      );
      await _db.insertScan(scan.toMap());
      await loadScans();
      state = state.copyWith(isProcessing: false, capturedImage: null);
      return scan;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isProcessing: false);
      return null;
    }
  }

  // Toggle favourite
  Future<void> toggleFavourite(String id) async {
    final scan = state.scans.firstWhere((s) => s.id == id);
    final updated = scan.copyWith(
      isFavorite: !scan.isFavorite,
      updatedAt: DateTime.now(),
    );
    await _db.updateScan(id, updated.toMap());
    await loadScans();
  }

  // Delete scan
  Future<void> deleteScan(String id) async {
    await _db.deleteScan(id);
    await loadScans();
  }

  // Search
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearCapturedImage() {
    state = state.copyWith(capturedImage: null);
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final scannerProvider = StateNotifierProvider<ScannerNotifier, ScannerState>(
  (_) => ScannerNotifier(),
);
