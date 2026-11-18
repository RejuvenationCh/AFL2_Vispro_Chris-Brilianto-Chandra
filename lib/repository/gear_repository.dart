import 'dart:convert';
import 'dart:io';

import '../models/gear.dart';
import '../models/gear_loan.dart';

class GearRepository {
  GearRepository(this._file);

  final File _file;
  final List<Gear> _items = [];
  int _nextId = 1;

  void add(String name) {
    final gear = Gear(_nextId, name);
    _items.add(gear);
    try {
      _save();
      _nextId++;
    } catch (_) {
      _items.removeLast();
      rethrow;
    }
  }

  List<Gear> list() {
    return List.of(_items);
  }

  // Return false if item is on a loan or is not existed into existence yet
  bool lend(int id, GearLoan loan) {
    for (var index = 0; index < _items.length; index++) {
      final gear = _items[index];

      if (gear.id == id) {
        if (gear.loan != null) {
          // False = Data found but is loaned
          return false;
        }
        _items[index] = Gear(
          gear.id,
          gear.name,
          loan: loan,
        );
        try {
          _save();
        } catch (_) {
          _items[index] = gear;
          rethrow;
        }
        // True = Gear is loaned
        return true;
      }
    }
    // Item not found
    return false;
  }

  bool returnGear(int id) {
    for (var index = 0; index < _items.length; index++) {
      final gear = _items[index];
      if (gear.id == id) {
        if (gear.loan == null) {
          return false;
        }
        _items[index] = Gear(gear.id, gear.name);
        try {
          _save();
        } catch (_) {
          _items[index] = gear;
          rethrow;
        }
        return true;
      }
    }
    return false;
  }

  void load() {
    if (!_file.existsSync()) return;

    final text = _file.readAsStringSync();
    final rows = jsonDecode(text) as List<dynamic>;
    final savedItems = <Gear>[];
    var nextId = 1;

    for (final row in rows) {
      final gear = Gear.fromJson(row as Map<String, dynamic>);
      savedItems.add(gear);
      if (gear.id >= nextId) nextId = gear.id + 1;
    }

    _items.clear();
    _items.addAll(savedItems);
    _nextId = nextId;
  }

  void _save() {
    final rows = <Map<String, dynamic>>[];
    for (final gear in _items) {
      rows.add(gear.toJson());
    }

    final temporary = File('${_file.path}.tmp');
    temporary.writeAsStringSync(jsonEncode(rows), flush: true);
    temporary.renameSync(_file.path);
  }
}
