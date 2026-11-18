import 'package:flutter/material.dart';

import '../viewmodels/inventory_view_model.dart';
import '../viewmodels/states/inventory_state.dart';
import '../domain/models/gear.dart';
import 'gear_details_page.dart';
import 'widgets/action_feedback.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage(this.viewModel, {super.key});

  final InventoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final state = viewModel.state;

        switch (state) {
          case InventoryLoading():
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case InventoryError():
            return Scaffold(
              appBar: AppBar(title: const Text('Gear Loan Log')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    TextButton(
                      onPressed: viewModel.load,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          case InventoryLoaded():
            break;
        }

        final items = viewModel.items;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gear Loan Log'),
          ),
          body: ListView(
            children: [
              if (items.isEmpty) const ListTile(title: Text('No gear yet')),
              for (final gear in items)
                ListTile(
                  title: Text(gear.name),
                  subtitle: Text(gearStatus(gear)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return GearDetailsPage(
                            gear,
                            viewModel,
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddGearDialog(context),
            label: const Text('Add gear'),
          ),
        );
      },
    );
  }

  String gearStatus(Gear gear) {
    final loan = gear.loan;
    if (loan == null) {
      return 'Available';
    } else {
      return 'On loan to ${loan.borrower}';
    }
  }

  void showAddGearDialog(BuildContext context) {
    var name = '';
    viewModel.resetAction();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            return PopScope(
              canPop: !viewModel.isSaving,
              child: AlertDialog(
                title: const Text('Add gear'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      enabled: !viewModel.isSaving,
                      decoration: const InputDecoration(labelText: 'Gear name'),
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    ActionFeedback(viewModel.actionState),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: viewModel.isSaving
                        ? null
                        : () {
                            Navigator.pop(dialogContext);
                          },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: viewModel.isSaving
                        ? null
                        : () async {
                            final saved = await viewModel.addGear(name);
                            if (dialogContext.mounted && saved) {
                              Navigator.pop(dialogContext);
                            }
                          },
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
