import 'package:flutter/foundation.dart';

import '../models/gear.dart';
import '../models/gear_loan.dart';
import '../domain/repositories/gear_repository.dart';
import 'inventory_state.dart';
import 'gear_action_state.dart';

class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel(this._repository);

  final GearRepository _repository;
  bool _disposed = false;
  bool _loading = false;

  InventoryState _state = const InventoryLoading();
  InventoryState get state => _state;

  GearActionState _actionState = const GearActionReady();
  GearActionState get actionState => _actionState;

  bool get isSaving => _actionState is GearActionSaving;

  List<Gear> get items {
    final currentState = _state;
    if (currentState is InventoryLoaded) {
      return currentState.items;
    }
    return const [];
  }

  Future<void> load() async {
    if (_disposed || _loading || isSaving) return;

    _loading = true;
    _setState(const InventoryLoading());
    try {
      await _repository.load();
      if (_disposed) return;
      _refreshItems();
    } catch (_) {
      if (_disposed) return;
      _setState(const InventoryError('Could not load your gear. Try again.'));
    } finally {
      _loading = false;
    }
  }

  void resetAction() {
    if (isSaving) return;
    _setActionState(const GearActionReady());
  }

  Future<bool> addGear(String name) async {
    if (_disposed || _loading || isSaving) return false;

    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      _setActionState(const GearActionError('Enter a gear name.'));
      return false;
    }

    _setActionState(const GearActionSaving());
    try {
      await _repository.add(cleanName);
      if (_disposed) return false;
      _refreshItems();
      _setActionState(const GearActionSaved());
      return true;
    } catch (_) {
      if (_disposed) return false;
      _setActionState(
        const GearActionError('Could not save your gear. Try again.'),
      );
      return false;
    }
  }

  Future<bool> lendGear(int id, String borrower, DateTime? dueDate) async {
    if (_disposed || _loading || isSaving) return false;

    final name = borrower.trim();
    if (name.isEmpty) {
      _setActionState(const GearActionError('Enter a borrower name.'));
      return false;
    }
    if (dueDate == null) {
      _setActionState(const GearActionError('Choose a due date.'));
      return false;
    }

    _setActionState(const GearActionSaving());
    try {
      final saved = await _repository.lend(id, GearLoan(name, dueDate));
      if (_disposed) return false;
      if (!saved) {
        _setActionState(
          const GearActionError('This item is no longer available.'),
        );
        return false;
      }
      _refreshItems();
      _setActionState(const GearActionSaved());
      return true;
    } catch (_) {
      if (_disposed) return false;
      _setActionState(
        const GearActionError('Could not save the loan. Try again.'),
      );
      return false;
    }
  }

  Future<bool> returnGear(int id) async {
    if (_disposed || _loading || isSaving) return false;

    _setActionState(const GearActionSaving());
    try {
      final saved = await _repository.returnGear(id);
      if (_disposed) return false;
      if (!saved) {
        _setActionState(
          const GearActionError('This item has no active loan to return.'),
        );
        return false;
      }
      _refreshItems();
      _setActionState(const GearActionSaved());
      return true;
    } catch (_) {
      if (_disposed) return false;
      _setActionState(
        const GearActionError('Could not save the return. Try again.'),
      );
      return false;
    }
  }

  void _refreshItems() {
    _setState(InventoryLoaded(_repository.list()));
  }

  void _setState(InventoryState nextState) {
    if (_disposed || _state == nextState) return;
    _state = nextState;
    notifyListeners();
  }

  void _setActionState(GearActionState nextState) {
    if (_disposed || _actionState == nextState) return;
    _actionState = nextState;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
