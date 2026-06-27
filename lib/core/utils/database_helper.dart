import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableScans} (
        id          TEXT PRIMARY KEY,
        title       TEXT NOT NULL,
        imagePath   TEXT NOT NULL,
        ocrText     TEXT DEFAULT '',
        createdAt   TEXT NOT NULL,
        updatedAt   TEXT NOT NULL,
        pageCount   INTEGER DEFAULT 1,
        isFavorite  INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tablePdfs} (
        id          TEXT PRIMARY KEY,
        title       TEXT NOT NULL,
        pdfPath     TEXT NOT NULL,
        pageCount   INTEGER DEFAULT 1,
        sizeBytes   INTEGER DEFAULT 0,
        createdAt   TEXT NOT NULL,
        scanId      TEXT,
        FOREIGN KEY (scanId) REFERENCES ${AppConstants.tableScans}(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations here
  }

  // ─── Scan CRUD ────────────────────────────────────────────────────────────

  Future<int> insertScan(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(AppConstants.tableScans, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllScans() async {
    final db = await database;
    return db.query(AppConstants.tableScans, orderBy: 'createdAt DESC');
  }

  Future<Map<String, dynamic>?> getScanById(String id) async {
    final db = await database;
    final rows = await db.query(AppConstants.tableScans, where: 'id = ?', whereArgs: [id]);
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<int> updateScan(String id, Map<String, dynamic> data) async {
    final db = await database;
    return db.update(AppConstants.tableScans, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteScan(String id) async {
    final db = await database;
    return db.delete(AppConstants.tableScans, where: 'id = ?', whereArgs: [id]);
  }

  // ─── PDF CRUD ─────────────────────────────────────────────────────────────

  Future<int> insertPdf(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(AppConstants.tablePdfs, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllPdfs() async {
    final db = await database;
    return db.query(AppConstants.tablePdfs, orderBy: 'createdAt DESC');
  }

  Future<int> deletePdf(String id) async {
    final db = await database;
    return db.delete(AppConstants.tablePdfs, where: 'id = ?', whereArgs: [id]);
  }
}
