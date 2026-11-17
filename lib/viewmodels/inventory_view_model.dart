import '../models/gear.dart';
import '../repository/gear_repository.dart';

import 'package:flutter/foundation.dart';

class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel(this._repository);

  final GearRepository _repository;

  List<Gear> get items {
    return _repository.list();
  }

  bool addGear(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      return false;
    }

    _repository.add(cleanName);
    notifyListeners();
    return true;
  }
}
