import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';

/// Thin singleton wrapper around the sqflite database instance.
/// All actual query logic lives in [CalculationRepository] - this class
/// only owns the connection + schema.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCalculations} (
        id TEXT PRIMARY KEY,
        customerName TEXT,
        width REAL NOT NULL,
        height REAL NOT NULL,
        unit TEXT NOT NULL,
        sqInch REAL NOT NULL,
        sqFeet REAL NOT NULL,
        sqMeter REAL NOT NULL,
        rate REAL NOT NULL,
        quantity REAL NOT NULL,
        subtotal REAL NOT NULL,
        gstEnabled INTEGER NOT NULL,
        gstPercent REAL NOT NULL,
        gstAmount REAL NOT NULL,
        roundOff INTEGER NOT NULL,
        grandTotal REAL NOT NULL,
        dateTime TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_calculations_dateTime ON ${AppConstants.tableCalculations} (dateTime)',
    );
    await db.execute(
      'CREATE INDEX idx_calculations_customerName ON ${AppConstants.tableCalculations} (customerName)',
    );
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
