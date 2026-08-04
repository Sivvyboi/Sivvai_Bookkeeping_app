import 'package:flutter/material.dart';
import '../models/local_customer.dart';

class RepaymentDialog extends StatefulWidget {
  final LocalCustomer customer;
  const RepaymentDialog({super.key, required this.customer});

  @override
  State<RepaymentDialog> createState() => _RepaymentDialogState();
}

class _RepaymentDialogState extends State<RepaymentDialog> {
  final _amountController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _fillFullAmount() {
    setState(() {
      // Formats value to 2 decimal places to avoid entry noise
      _amountController.text = widget.customer.totalDebtAmount.toStringAsFixed(2);
      _errorText = null;
    });
  }

  Future<void> _validateAndConfirm() async {
    final String text = _amountController.text.trim().replaceAll(',', '');
    if (text.isEmpty) {
      setState(() => _errorText = 'Enter an amount');
      return;
    }

    final double? amount = double.tryParse(text);

    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Please enter a valid positive amount');
      return;
    }

    // --- STEP 2: BOUNDARY CHECK ---
    if (amount > widget.customer.totalDebtAmount) {
      final bool? confirmFull = await showDialog<bool>(
        context: context,
        builder: (alertCtx) => AlertDialog(
          content: Text(
              "The amount cannot be more than the balance to be paid (Outstanding: ₦${widget.customer.totalDebtAmount.toStringAsFixed(2)}). Is this amount intended as the full payment of this debt/credit?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertCtx, false), // "No": dismiss and stay in entry dialog
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(alertCtx, true), // "Yes": override to match balance
              child: const Text("Yes"),
            ),
          ],
        ),
      );

      if (confirmFull == true) {
        // Automatically override and update the text input controller to match the exact figure
        _amountController.text = widget.customer.totalDebtAmount.toStringAsFixed(2);
        // Close the alerts (this dialog) and proceed with returning the amount
        if (mounted) Navigator.pop(context, widget.customer.totalDebtAmount);
      }
      // If "No", alert is dismissed and user remains on this sheet to adjust inputs
      return;
    }

    // Returns the validated double back to the caller in debt_ledger_screen
    Navigator.pop(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        widget.customer.relationType == 'CREDITOR' ? 'Settle Credit Balance' : 'Settle Debt Balance',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remaining Balance: ₦${widget.customer.totalDebtAmount.toStringAsFixed(2)}',
            style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount to Pay',
                    errorText: _errorText,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixText: '₦ ',
                  ),
                  onChanged: (val) {
                    if (_errorText != null) setState(() => _errorText = null);
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 56, 
                child: TextButton(
                  onPressed: _fillFullAmount,
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'FULL',
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: Text('Cancel', style: TextStyle(color: theme.colorScheme.error)),
        ),
        ElevatedButton(
          onPressed: _validateAndConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
