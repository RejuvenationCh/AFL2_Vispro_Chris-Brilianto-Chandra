import 'package:flutter/material.dart';

import '../viewmodels/inventory_view_model.dart';
import '../models/gear.dart';
import 'gear_details_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage(this.viewModel, {super.key});

  final InventoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
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
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add gear'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Gear name'),
            onChanged: (value) {
              name = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                try {
                  if (viewModel.addGear(name)) {
                    Navigator.pop(dialogContext);
                  }
                } catch (_) {
                  showSaveError(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showSaveError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not save your change. Try again.'),
      ),
    );
  }
}
