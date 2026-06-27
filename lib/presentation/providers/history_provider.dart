import 'package:flutter/material.dart';

import '../../data/models/calculation_record.dart';
import '../../data/repositories/calculation_repository.dart';

class HistoryProvider extends ChangeNotifier {
  final CalculationRepository _repository = CalculationRepository();

  List<CalculationRecord> _records = [];
  String _query = '';
  bool _loading = false;

  List<CalculationRecord> get records => _records;
  String get query => _query;
  bool get loading => _loading;
  bool get isEmpty => _records.isEmpty;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _records = _query.isEmpty
        ? await _repository.getAll()
        : await _repository.search(_query);
    _loading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _query = query;
    await load();
  }

  Future<void> deleteRecord(String id) async {
    await _repository.delete(id);
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    _records = [];
    notifyListeners();
  }

  Future<void> updateRecord(CalculationRecord record) async {
    await _repository.update(record);
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _records[index] = record;
    }
    notifyListeners();
  }
}
