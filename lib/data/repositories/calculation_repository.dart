import '../../core/constants/app_constants.dart';
import '../database/database_helper.dart';
import '../models/calculation_record.dart';

/// Data-access layer for [CalculationRecord]. Screens never talk to
/// sqflite directly - they go through this repository, which keeps the
/// SQL contained in one place and makes future migration (e.g. to a
/// remote backend) painless.
class CalculationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> insert(CalculationRecord record) async {
    final db = await _dbHelper.database;
    await db.insert(AppConstants.tableCalculations, record.toMap());
  }

  Future<void> update(CalculationRecord record) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableCalculations,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.tableCalculations,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    final db = await _dbHelper.database;
    await db.delete(AppConstants.tableCalculations);
  }

  Future<List<CalculationRecord>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      AppConstants.tableCalculations,
      orderBy: 'dateTime DESC',
    );
    return rows.map(CalculationRecord.fromMap).toList();
  }

  /// Searches by customer name OR by a free-text numeric match against
  /// width/height/grand total - handy for shop owners who remember "the
  /// 12x18 one" or "the ₹500 order" rather than a customer name.
  Future<List<CalculationRecord>> search(String query) async {
    final db = await _dbHelper.database;
    final trimmed = query.trim();
    if (trimmed.isEmpty) return getAll();

    final rows = await db.query(
      AppConstants.tableCalculations,
      where: '''
        customerName LIKE ? OR
        CAST(width AS TEXT) LIKE ? OR
        CAST(height AS TEXT) LIKE ? OR
        CAST(grandTotal AS TEXT) LIKE ?
      ''',
      whereArgs: List.filled(4, '%$trimmed%'),
      orderBy: 'dateTime DESC',
    );
    return rows.map(CalculationRecord.fromMap).toList();
  }

  Future<int> count() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableCalculations}',
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
