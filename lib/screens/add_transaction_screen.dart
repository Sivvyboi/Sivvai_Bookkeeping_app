import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../models/local_customer.dart';
import '../models/local_transaction.dart';
import '../utils/size_config.dart';
import '../widgets/calculator_widget.dart';

class AddTransactionScreen extends StatefulWidget {
  final LocalTransaction? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  final _customerSearchController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _transactionType = 'INFLOW';
  bool _isCredit = false;
  LocalCustomer? _selectedCustomer;
  bool _isNewCustomer = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _remarksController.text = widget.transaction!.remarks ?? '';
      _transactionType = widget.transaction!.transactionType;
      _isCredit = widget.transaction!.isCredit;
      if (widget.transaction!.customer.value != null) {
        _selectedCustomer = widget.transaction!.customer.value;
        _customerSearchController.text = _selectedCustomer!.fullName;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    _customerSearchController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    var amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount');
      return;
    }

    if (_isCredit && _selectedCustomer == null && _customerSearchController.text.trim().isEmpty) {
      _showSnackBar('Please select or enter a customer for credit transactions');
      return;
    }

    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    LocalCustomer? customerToLink = _selectedCustomer;
    if (_isCredit && _selectedCustomer == null) {
      customerToLink = LocalCustomer()
        ..fullName = _customerSearchController.text.trim()
        ..phoneNumber = _phoneController.text.trim()
        ..relationType = _transactionType == 'INFLOW' ? 'DEBTOR' : 'CREDITOR';
    }

    // --- NEW LEDGER BUG INTERCEPTION FLOW ---
    if (_isCredit && _selectedCustomer != null) {
      bool hasOpposingDirection = false;

      // Determine if the current transaction intent matches the opposing side
      if (_selectedCustomer!.relationType == 'DEBTOR' && _transactionType == 'OUTFLOW') {
        hasOpposingDirection = true; // They normally owe you, but you're logging an expense out to them
      } else if (_selectedCustomer!.relationType == 'CREDITOR' && _transactionType == 'INFLOW') {
        hasOpposingDirection = true; // You normally owe them, but you're logging income in from them
      }

      if (hasOpposingDirection) {
        if (_selectedCustomer!.totalDebtAmount > 0) {
          final String currentOpposingRole = _selectedCustomer!.relationType;

        bool? isRepayment = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('Match Balance?'),
            content: Text(
                '${_selectedCustomer!.fullName} currently has an active balance as a $currentOpposingRole.\n\nIs this entry a repayment/settlement for that existing balance, or a separate new ledger item?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx, false), // Keep Separate
                child: const Text('Separate Record'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Step 2: Boundary check for Repayment action
                  if (amount! > _selectedCustomer!.totalDebtAmount) {
                    final bool? confirmFull = await showDialog<bool>(
                      context: context,
                      builder: (alertCtx) => AlertDialog(
                        content: Text(
                            "The amount cannot be more than the balance to be paid (Outstanding: ₦${_selectedCustomer!.totalDebtAmount.toStringAsFixed(2)}). Is this amount intended as the full payment of this debt/credit?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(alertCtx, false),
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(alertCtx, true),
                            child: const Text("Yes"),
                          ),
                        ],
                      ),
                    );

                    if (confirmFull == true) {
                      // Override amount to match balance
                      _amountController.text = _selectedCustomer!.totalDebtAmount.toStringAsFixed(2);
                      if (context.mounted) Navigator.pop(dialogCtx, true);
                    } else {
                      // Dismiss alert and return to entry sheet
                      if (context.mounted) Navigator.pop(dialogCtx, null);
                    }
                  } else {
                    Navigator.pop(dialogCtx, true);
                  }
                },
                child: const Text('Repayment'),
              ),
            ],
          ),
        );

        if (isRepayment == null) return; // User closed dialog or clicked No in boundary check

        if (isRepayment) {
          // Sync amount in case it was updated in the boundary confirmation dialog
          amount = double.tryParse(_amountController.text) ?? amount;

          // Process immediately as a repayment settlement
          await provider.settleLedgerBalance(
            customerId: _selectedCustomer!.id,
            amountPaid: amount,
            isCreditor: currentOpposingRole == 'CREDITOR',
          );

          if (!mounted) return;
          navigator.pop();
          return;
          } else {
             // --- AUTO-CREATE SEPARATE LEDGER PROFILE (ACTIVE BALANCE BYPASS) ---
             // User explicitly chose 'Separate Record' in the modal despite an active opposing balance.
             // We clone them cleanly to isolate the new debt track, stripping previous messy suffixes.
             final String baseName = _selectedCustomer!.fullName.replaceAll(RegExp(r'\s*\((Debtor|Creditor)\)'), '');
             final String suffix = _transactionType == 'INFLOW' ? '(Debtor)' : '(Creditor)';

             customerToLink = LocalCustomer()
               ..fullName = '$baseName $suffix'
               ..phoneNumber = _selectedCustomer!.phoneNumber
               ..relationType = _transactionType == 'INFLOW' ? 'DEBTOR' : 'CREDITOR';

             _selectedCustomer = null;
          }
        }
        // If totalDebtAmount == 0, we do NOTHING! 
        // It seamlessly falls through and reuses the existing profile. 
        // The database will now securely switch their relationType on the fly!
      }
    }
    // --- END INTERCEPTION FLOW ---

    // Save normally if it's a completely separate transaction or no conflict exists
    if (widget.transaction != null) {
      await provider.updateTransaction(
        id: widget.transaction!.id,
        amount: amount,
        type: _transactionType,
        remarks: _remarksController.text.trim(),
        customer: _isCredit ? customerToLink : null,
        isCredit: _isCredit,
      );
    } else {
      await provider.saveQuickTransaction(
        amount: amount,
        type: _transactionType,
        remarks: _remarksController.text.trim(),
        customer: _isCredit ? customerToLink : null,
        isCredit: _isCredit,
      );
    }

    if (!mounted) return;

    if (provider.errorMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    } else {
      navigator.pop();
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    
    bool isExpense = _transactionType == 'OUTFLOW';
    Color transactionColor = isExpense ? statusColors.outflow! : statusColors.inflow!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.transaction != null ? 'Edit Transaction' : 'New Transaction', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)
        ),
        backgroundColor: isDark ? theme.colorScheme.surface : transactionColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.transaction != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Input Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount', style: theme.textTheme.labelSmall),
                IconButton(
                  icon: Icon(
                    Icons.calculate_outlined,
                    color: transactionColor,
                    size: 22.sp,
                  ),
                  tooltip: 'Calculator',
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    CalculatorModalSheet.show(
                      context: context,
                      accentColor: transactionColor,
                      onResultConfirmed: (val) {
                        setState(() {
                          String formatted = val == val.toInt().toDouble()
                              ? val.toInt().toString()
                              : val.toStringAsFixed(2);
                          _amountController.text = formatted;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
            TextField(
              controller: _amountController,
              autofocus: widget.transaction == null,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 42.sp, fontWeight: FontWeight.bold, color: transactionColor),
              decoration: InputDecoration(
                prefixText: '₦ ',
                prefixStyle: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: transactionColor),
                hintText: '0.00',
                hintStyle: TextStyle(color: transactionColor.withValues(alpha: 0.3)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            Divider(thickness: 1, color: theme.dividerTheme.color),
            SizedBox(height: 3.h),

            // Category Selection
            Text('Transaction Type', style: theme.textTheme.titleMedium),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                _buildTypeButton('Sale / Income', 'INFLOW', statusColors.inflow!, theme),
                SizedBox(width: 3.w),
                _buildTypeButton('Expense', 'OUTFLOW', statusColors.outflow!, theme),
              ],
            ),
            SizedBox(height: 4.h),

            // Remarks Input
            Text('Remarks', style: theme.textTheme.titleMedium),
            SizedBox(height: 1.h),
            TextField(
              controller: _remarksController,
              decoration: InputDecoration(
                hintText: 'What was this for?',
                prefixIcon: const Icon(Icons.notes),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 4.h),

            // Credit Toggle Card
            Card(
              elevation: 0,
              color: transactionColor.withValues(alpha: isDark ? 0.1 : 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: transactionColor.withValues(alpha: 0.2)),
              ),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.credit_card, color: transactionColor),
                            SizedBox(width: 2.w),
                            Text(
                              isExpense ? 'Expense on Credit?' : 'Sale on Credit?', 
                              style: TextStyle(fontWeight: FontWeight.bold, color: transactionColor, fontSize: 14.sp)
                            ),
                          ],
                        ),
                        Switch(
                          value: _isCredit,
                          onChanged: (val) => setState(() => _isCredit = val),
                          activeThumbColor: transactionColor,
                        ),
                      ],
                    ),
                    if (_isCredit) ...[
                      SizedBox(height: 2.h),
                      _buildCustomerSelector(
                        isExpense ? 'Select Creditor' : 'Select Debtor', 
                        theme,
                        transactionColor
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_isNewCustomer && _isCredit) ...[
              SizedBox(height: 3.h),
              Text('New Contact Details', style: theme.textTheme.titleMedium),
              SizedBox(height: 1.5.h),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],

            SizedBox(height: 6.h),
            
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: transactionColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                widget.transaction != null ? 'Update Transaction' : 'Save Transaction',
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone and will update your balances.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final provider = context.read<TransactionProvider>();
              final navigator = Navigator.of(context);
              await provider.deleteTransaction(widget.transaction!.id);
              if (mounted) {
                navigator.pop(); // Close dialog
                navigator.pop(); // Go back to home
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSelector(String hint, ThemeData theme, Color accentColor) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Autocomplete<LocalCustomer>(
          displayStringForOption: (option) => option.fullName,
          initialValue: TextEditingValue(text: _customerSearchController.text),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return provider.customers;
            }
            return provider.customers.where((c) =>
                c.fullName.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (selection) {
            setState(() {
              _selectedCustomer = selection;
              _isNewCustomer = false;
              _customerSearchController.text = selection.fullName;
            });
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8.0,
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80.w,
                  constraints: BoxConstraints(maxHeight: 30.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerTheme.color!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (ctx, idx) => Divider(height: 1, color: theme.dividerTheme.color),
                    itemBuilder: (BuildContext context, int index) {
                      final LocalCustomer option = options.elementAt(index);
                      return ListTile(
                        title: Text(option.fullName, style: theme.textTheme.bodyLarge),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (val) {
                setState(() {
                  _isNewCustomer = false;
                  _selectedCustomer = null;
                  _customerSearchController.text = val;
                });
              },
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: (controller.text.isNotEmpty && 
                            !provider.customers.any((c) => c.fullName.toLowerCase() == controller.text.toLowerCase()))
                    ? IconButton(
                        icon: const Icon(Icons.person_add_alt_1),
                        tooltip: 'Add as new contact',
                        onPressed: () {
                          setState(() {
                            _isNewCustomer = true;
                            _selectedCustomer = null;
                            _customerSearchController.text = controller.text;
                          });
                        },
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeButton(String label, String type, Color color, ThemeData theme) {
    bool isSelected = _transactionType == type;
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _transactionType = type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected ? color : (isDark ? theme.colorScheme.surface : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : theme.dividerTheme.color!,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color, 
                fontWeight: FontWeight.bold, 
                fontSize: 14.sp
              ),
            ),
          ),
        ),
      ),
    );
  }
}
