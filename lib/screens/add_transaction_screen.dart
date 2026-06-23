import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/local_customer.dart';
import '../models/local_transaction.dart';
import '../utils/size_config.dart';

class AddTransactionScreen extends StatefulWidget {
  final LocalTransaction? transaction;
  
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  final _phoneController = TextEditingController();
  final _customerSearchController = TextEditingController();

  late String _transactionType;
  late bool _isCredit;
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
      
      widget.transaction!.customer.load().then((_) {
        if (mounted) {
          setState(() {
            _selectedCustomer = widget.transaction!.customer.value;
            if (_selectedCustomer != null) {
              _customerSearchController.text = _selectedCustomer!.fullName;
            }
          });
        }
      });
    } else {
      _transactionType = 'INFLOW';
      _isCredit = false;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    _phoneController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showSnackBar('Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount');
      return;
    }

    final provider = context.read<TransactionProvider>();
    LocalCustomer? customerToLink = _selectedCustomer;

    // Determine relation type for customer
    String relationType = (_transactionType == 'OUTFLOW') ? 'CREDITOR' : 'DEBTOR';

    if (_isCredit && _isNewCustomer && _customerSearchController.text.trim().isNotEmpty) {
      customerToLink = await provider.addCustomer(
        _customerSearchController.text.trim(),
        phone: _phoneController.text.trim(),
        relationType: relationType,
      );
    }

    if (_isCredit && customerToLink == null) {
      _showSnackBar('Please select or create a contact for this transaction');
      return;
    }

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

    if (mounted) {
      if (provider.errorMessage != null) {
        _showSnackBar(provider.errorMessage!);
      } else {
        Navigator.pop(context);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    bool isExpense = _transactionType == 'OUTFLOW';
    Color themeColor = isExpense ? Colors.red : Colors.green;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.transaction != null ? 'Edit Transaction' : 'New Transaction', 
                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(20))),
        backgroundColor: themeColor,
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
        padding: EdgeInsets.all(SizeConfig.blockWidth(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(14))),
            TextField(
              controller: _amountController,
              autofocus: widget.transaction == null,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: SizeConfig.setSp(48), fontWeight: FontWeight.bold, color: themeColor),
              decoration: const InputDecoration(
                prefixText: '₦ ',
                hintText: '0.00',
                border: InputBorder.none,
              ),
            ),
            const Divider(thickness: 1.5),
            SizedBox(height: SizeConfig.blockHeight(3)),

            Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(16))),
            SizedBox(height: SizeConfig.blockHeight(1.5)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeButton('Sale / Income', 'INFLOW', Colors.green),
                  SizedBox(width: SizeConfig.blockWidth(2)),
                  _buildTypeButton('Expense', 'OUTFLOW', Colors.red),
                ],
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight(4)),

            Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(16))),
            SizedBox(height: SizeConfig.blockHeight(1)),
            TextField(
              controller: _remarksController,
              style: TextStyle(fontSize: SizeConfig.setSp(14)),
              decoration: InputDecoration(
                hintText: 'What was this for?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizeConfig.blockWidth(3))),
                contentPadding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth(4), vertical: SizeConfig.blockHeight(1.5)),
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight(4)),

            Container(
              margin: EdgeInsets.only(bottom: SizeConfig.blockHeight(4)),
              padding: EdgeInsets.all(SizeConfig.blockWidth(4)),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(SizeConfig.blockWidth(4)),
                border: Border.all(color: themeColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isExpense ? 'Expense on Credit?' : 'Sale on Credit?', 
                          style: TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: SizeConfig.setSp(14))),
                      Switch(
                        value: _isCredit,
                        onChanged: (val) => setState(() => _isCredit = val),
                        activeThumbColor: themeColor,
                        activeTrackColor: themeColor.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  if (_isCredit) ...[
                    SizedBox(height: SizeConfig.blockHeight(2)),
                    _buildCustomerSelector(isExpense ? 'Creditor (Who you owe)' : 'Debtor (Who owes you)'),
                  ],
                ],
              ),
            ),

            if (_isNewCustomer && _isCredit) ...[
              Text('New Contact Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(16))),
              SizedBox(height: SizeConfig.blockHeight(1.5)),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: SizeConfig.setSp(14)),
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizeConfig.blockWidth(3))),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight(4)),
            ],

            SizedBox(
              width: double.infinity,
              height: SizeConfig.blockHeight(7),
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SizeConfig.blockWidth(4))),
                  elevation: 2,
                ),
                child: Text(widget.transaction != null ? 'Update Transaction' : 'Save Transaction', 
                           style: TextStyle(fontSize: SizeConfig.setSp(18), fontWeight: FontWeight.bold)),
              ),
            ),
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
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final provider = context.read<TransactionProvider>();
              await provider.deleteTransaction(widget.transaction!.id);
              if (mounted) {
                Navigator.pop(context); 
                Navigator.pop(context); 
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSelector(String hint) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Autocomplete<LocalCustomer>(
          displayStringForOption: (option) => option.fullName,
          initialValue: TextEditingValue(text: _customerSearchController.text),
          optionsBuilder: (TextEditingValue textEditingValue) {
            // provider.customers is already sorted by lastUsed desc from the DatabaseService
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
                elevation: 4.0,
                borderRadius: BorderRadius.circular(SizeConfig.blockWidth(3)),
                child: Container(
                  width: SizeConfig.screenWidth - SizeConfig.blockWidth(20), // Constrain width
                  constraints: BoxConstraints(maxHeight: SizeConfig.blockHeight(30)), // Constrain height
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final LocalCustomer option = options.elementAt(index);
                      return ListTile(
                        title: Text(option.fullName, style: TextStyle(fontSize: SizeConfig.setSp(14))),
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
              style: TextStyle(fontSize: SizeConfig.setSp(14)),
              onChanged: (val) {
                setState(() {
                  _isNewCustomer = false;
                  _selectedCustomer = null;
                  _customerSearchController.text = val;
                });
              },
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: const Icon(Icons.person_search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(SizeConfig.blockWidth(3))),
                suffixIcon: (controller.text.isNotEmpty && 
                            !provider.customers.any((c) => c.fullName.toLowerCase() == controller.text.toLowerCase()))
                    ? IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.indigo),
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

  Widget _buildTypeButton(String label, String type, Color color) {
    bool isSelected = _transactionType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _transactionType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight(1.5), horizontal: SizeConfig.blockWidth(4)),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth(3)),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(14)),
          ),
        ),
      ),
    );
  }
}
