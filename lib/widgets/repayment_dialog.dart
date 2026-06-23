import 'package:flutter/material.dart';
import '../models/local_customer.dart';
import '../utils/size_config.dart';

class RepaymentDialog extends StatefulWidget {
  final LocalCustomer customer;

  const RepaymentDialog({super.key, required this.customer});

  @override
  State<RepaymentDialog> createState() => _RepaymentDialogState();
}

class _RepaymentDialogState extends State<RepaymentDialog> {
  final _amountController = TextEditingController();
  bool _canConfirm = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateConfirmState);
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateConfirmState);
    _amountController.dispose();
    super.dispose();
  }

  void _updateConfirmState() {
    final text = _amountController.text;
    final amount = double.tryParse(text) ?? 0;
    setState(() {
      _canConfirm = text.isNotEmpty && amount > 0;
      if (amount > widget.customer.totalDebtAmount + 0.01) {
        _errorText = 'Exceeds balance. Will cap to ₦${widget.customer.totalDebtAmount.toStringAsFixed(2)}';
      } else {
        _errorText = null;
      }
    });
  }

  void _fillFullPayment() {
    setState(() {
      _amountController.text = widget.customer.totalDebtAmount.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final isDebtor = widget.customer.relationType == 'DEBTOR';
    final title = isDebtor ? 'Settle Debtor Balance' : 'Settle Creditor Balance';
    final color = isDebtor ? Colors.green : Colors.red;

    return AlertDialog(
      title: Text(title, 
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(20))),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance: ₦ ${widget.customer.totalDebtAmount.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[600], fontSize: SizeConfig.setSp(14)),
            ),
            SizedBox(height: SizeConfig.blockHeight(2)),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(fontSize: SizeConfig.setSp(16)),
              decoration: InputDecoration(
                labelText: 'Amount Paid',
                labelStyle: TextStyle(fontSize: SizeConfig.setSp(14)),
                prefixText: '₦ ',
                border: const OutlineInputBorder(),
                errorText: _errorText,
                errorStyle: TextStyle(fontSize: SizeConfig.setSp(12)),
                suffixIcon: TextButton(
                  onPressed: _fillFullPayment,
                  child: Text('Full', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(14))),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', 
            style: TextStyle(color: Colors.grey, fontSize: SizeConfig.setSp(14))),
        ),
        ElevatedButton(
          onPressed: _canConfirm
              ? () {
                  double amount = double.tryParse(_amountController.text) ?? 0;
                  if (amount > widget.customer.totalDebtAmount) {
                    amount = widget.customer.totalDebtAmount;
                  }
                  Navigator.pop(context, amount);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth(4), 
              vertical: SizeConfig.blockHeight(1)
            ),
          ),
          child: Text('Confirm', style: TextStyle(fontSize: SizeConfig.setSp(14))),
        ),
      ],
    );
  }
}
