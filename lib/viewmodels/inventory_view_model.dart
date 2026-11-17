import '../models/gear.dart';
import '../repository/gear_repository.dart';

class InventoryViewModel {
  InventoryViewModel(this._repository);

  final GearRepository _repository;

  List<Gear> get items {
    return _repository.list();
  }
}
