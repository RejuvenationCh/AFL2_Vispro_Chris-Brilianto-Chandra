import 'package:flutter/material.dart';

import '../models/gear.dart';
import '../viewmodels/inventory_view_model.dart';
import 'widgets/action_feedback.dart';

class GearDetailsPage extends StatelessWidget {
  const GearDetailsPage(
    this.gear,
    this.viewModel, {
    super.key,
  });

  final Gear gear;
  final InventoryViewModel viewModel;

  Gear get currentGear {
    return viewModel.items.firstWhere(
      (item) => item.id == gear.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gear.name),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gearStatus()),
                const SizedBox(height: 24),
                if (currentGear.loan == null)
                  FilledButton(
                    onPressed: () {
                      showLendDialog(context, gear.id);
                    },
                    child: const Text('Lend gear'),
                  ),
                if (currentGear.loan != null)
                  FilledButton(
                    onPressed: () {
                      showReturnDialog(context, gear.id);
                    },
                    child: const Text('Mark returned'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String gearStatus() {
    final loan = currentGear.loan;

    if (loan == null) {
      return 'Available';
    } else {
      return 'On loan to ${loan.borrower}\n'
          'Due at : ${loan.dueDate.day}/${loan.dueDate.month}/${loan.dueDate.year}';
    }
  }

  void showLendDialog(BuildContext context, int gearId) {
    var borrower = '';
    DateTime? dueDate;
    viewModel.resetAction();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDate) {
            return ListenableBuilder(
              listenable: viewModel,
              builder: (context, child) {
                var dateLabel = 'Choose due date';
                if (dueDate != null) {
                  dateLabel = MaterialLocalizations.of(context)
                      .formatMediumDate(dueDate!);
                }

                return PopScope(
                  canPop: !viewModel.isSaving,
                  child: AlertDialog(
                    title: const Text('Lend gear'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          enabled: !viewModel.isSaving,
                          decoration: const InputDecoration(
                            labelText: 'Borrower name',
                          ),
                          onChanged: (value) {
                            borrower = value;
                          },
                        ),
                        TextButton(
                          onPressed: viewModel.isSaving
                              ? null
                              : () async {
                                  final today = DateUtils.dateOnly(
                                    DateTime.now(),
                                  );
                                  final currentDate = dueDate ?? today;
                                  final picked = await showDatePicker(
                                    context: dialogContext,
                                    initialDate: currentDate,
                                    firstDate: currentDate.isBefore(today)
                                        ? currentDate
                                        : today,
                                    lastDate: DateTime(today.year + 5),
                                  );
                                  if (!dialogContext.mounted ||
                                      picked == null) {
                                    return;
                                  }
                                  updateDate(() {
                                    dueDate = picked;
                                  });
                                },
                          child: Text(dateLabel),
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
                                final saved = await viewModel.lendGear(
                                  gearId,
                                  borrower,
                                  dueDate,
                                );
                                if (dialogContext.mounted && saved) {
                                  Navigator.pop(dialogContext);
                                }
                              },
                        child: const Text('Lend gear'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void showReturnDialog(BuildContext context, int gearId) {
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
                title: const Text('Return gear?'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Mark this item as available again?'),
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
                            final saved = await viewModel.returnGear(gearId);
                            if (dialogContext.mounted && saved) {
                              Navigator.pop(dialogContext);
                            }
                          },
                    child: const Text('Mark returned'),
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
