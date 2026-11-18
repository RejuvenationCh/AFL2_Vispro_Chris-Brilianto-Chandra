import 'dart:convert';
import 'dart:io';

import '../../domain/models/gear.dart';
import '../../domain/models/gear_loan.dart';

import '../../domain/repositories/gear_repository.dart';

class JsonGearRepository implements GearRepository {
  JsonGearRepository(this._file);

  final File _file;
  final List<Gear> _items = [];
  int _nextId = 1;

  @override
  Future<void> add(String name) async {
    final gear = Gear(_nextId, name);
    _items.add(gear);
    try {
      await _save();
      _nextId++;
    } catch (_) {
      _items.removeLast();
      rethrow;
    }
  }

  @override
  List<Gear> list() {
    return List.of(_items);
  }

  // Return false if item is on a loan or is not existed into existence yet
  @override
  Future<bool> lend(int id, GearLoan loan) async {
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
          await _save();
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

  @override
  Future<bool> returnGear(int id) async {
    for (var index = 0; index < _items.length; index++) {
      final gear = _items[index];
      if (gear.id == id) {
        if (gear.loan == null) {
          return false;
        }
        _items[index] = Gear(gear.id, gear.name);
        try {
          await _save();
        } catch (_) {
          _items[index] = gear;
          rethrow;
        }
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> load() async {
    if (!await _file.exists()) return;

    final text = await _file.readAsString();
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

  Future<void> _save() async {
    final rows = <Map<String, dynamic>>[];
    for (final gear in _items) {
      rows.add(gear.toJson());
    }

    final temporary = File('${_file.path}.tmp');
    await temporary.writeAsString(jsonEncode(rows), flush: true);
    await temporary.rename(_file.path);
  }
}
