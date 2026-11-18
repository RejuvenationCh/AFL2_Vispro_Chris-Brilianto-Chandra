import 'package:equatable/equatable.dart';

import '../../domain/models/gear.dart';

sealed class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

class InventoryLoaded extends InventoryState {
  InventoryLoaded(List<Gear> items) : items = List.unmodifiable(items);

  final List<Gear> items;

  @override
  List<Object?> get props => [items];
}

class InventoryError extends InventoryState {
  const InventoryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
