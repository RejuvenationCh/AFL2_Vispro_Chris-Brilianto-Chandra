import 'package:equatable/equatable.dart';

sealed class GearActionState extends Equatable {
  const GearActionState();

  @override
  List<Object?> get props => [];
}

class GearActionReady extends GearActionState {
  const GearActionReady();
}

class GearActionSaving extends GearActionState {
  const GearActionSaving();
}

class GearActionSaved extends GearActionState {
  const GearActionSaved();
}

class GearActionError extends GearActionState {
  const GearActionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
