import '../../domain/repositories/gear_repository.dart';
import '../../models/gear.dart';
import '../../models/gear_loan.dart';

class MemoryGearRepository implements GearRepository {
  final List<Gear> _items = [];
  int _nextId = 1;

  @override
  Future<void> load() async {}

  @override
  List<Gear> list() {
    return List.of(_items);
  }

  @override
  Future<void> add(String name) async {
    _items.add(Gear(_nextId, name));
    _nextId++;
  }

  @override
  Future<bool> lend(int id, GearLoan loan) async {
    for (var index = 0; index < _items.length; index++) {
      final gear = _items[index];
      if (gear.id == id) {
        if (gear.loan != null) return false;

        _items[index] = Gear(gear.id, gear.name, loan: loan);
        return true;
      }
    }
    return false;
  }

  @override
  Future<bool> returnGear(int id) async {
    for (var index = 0; index < _items.length; index++) {
      final gear = _items[index];
      if (gear.id == id) {
        if (gear.loan == null) return false;

        _items[index] = Gear(gear.id, gear.name);
        return true;
      }
    }
    return false;
  }
}
