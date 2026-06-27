class ScanModel {
  final String id;
  final String title;
  final String imagePath;
  final String ocrText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int pageCount;
  final bool isFavorite;

  const ScanModel({
    required this.id,
    required this.title,
    required this.imagePath,
    this.ocrText = '',
    required this.createdAt,
    required this.updatedAt,
    this.pageCount = 1,
    this.isFavorite = false,
  });

  factory ScanModel.fromMap(Map<String, dynamic> map) {
    return ScanModel(
      id:          map['id'] as String,
      title:       map['title'] as String,
      imagePath:   map['imagePath'] as String,
      ocrText:     map['ocrText'] as String? ?? '',
      createdAt:   DateTime.parse(map['createdAt'] as String),
      updatedAt:   DateTime.parse(map['updatedAt'] as String),
      pageCount:   map['pageCount'] as int? ?? 1,
      isFavorite:  (map['isFavorite'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':         id,
    'title':      title,
    'imagePath':  imagePath,
    'ocrText':    ocrText,
    'createdAt':  createdAt.toIso8601String(),
    'updatedAt':  updatedAt.toIso8601String(),
    'pageCount':  pageCount,
    'isFavorite': isFavorite ? 1 : 0,
  };

  ScanModel copyWith({
    String? title,
    String? ocrText,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return ScanModel(
      id:         id,
      title:      title      ?? this.title,
      imagePath:  imagePath,
      ocrText:    ocrText    ?? this.ocrText,
      createdAt:  createdAt,
      updatedAt:  updatedAt  ?? this.updatedAt,
      pageCount:  pageCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
