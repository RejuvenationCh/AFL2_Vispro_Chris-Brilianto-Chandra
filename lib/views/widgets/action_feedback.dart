import 'package:flutter/material.dart';

import '../../viewmodels/states/gear_action_state.dart';

class ActionFeedback extends StatelessWidget {
  const ActionFeedback(
    this.state, {
    super.key,
  });

  final GearActionState state;

  @override
  Widget build(BuildContext context) {
    final currentState = state;
    switch (currentState) {
      case GearActionReady():
        return const SizedBox.shrink();
      case GearActionSaving():
        return const Padding(
          padding: EdgeInsets.only(top: 12),
          child: LinearProgressIndicator(),
        );
      case GearActionSaved():
        return const Text('Saved.');
      case GearActionError():
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(
            liveRegion: true,
            child: Text(
              currentState.message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
    }
  }
}
