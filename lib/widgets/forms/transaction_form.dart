import 'dart:async';

import 'package:bfinance/features/dashboard/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/services/api_service.dart';
import 'package:bfinance/services/transaction_service.dart';

import 'package:provider/provider.dart';
import 'package:bfinance/providers/category_provider.dart';

class AddTransactionForm extends StatefulWidget {
  const AddTransactionForm({super.key});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  bool _isIncome = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final ApiService api = ApiService();

  //Defining the Error variable
  String? _amountError;

  // Implement the logic to add transaction to the database
  Future<void> _addTransaction() async {
    setState(() {
      _amountError = null;
    });
    //Basic validation
    double? amount; // Declare amount variable

    try {
      amount = double.parse(_amountController.text);
    } catch (e) {
      print("Invalid amount format: $e");
      setState(() {
        _amountError = "Please enter a valid number for amount";
      });
      return;
    }

    final categoryProvider = context.read<CategoryProvider>();
    final Transaction transaction_data = Transaction(
      id: null,
      title: _titleController.text,
      date: DateTime.now().toString(),
      amount: amount,
      type: _isIncome ? TransactionType.income : TransactionType.expense,
      time: DateTime.now().toString(),
      note: _noteController.text == "" ? null : _noteController.text,
      category: categoryProvider.selectedCategoryId ?? 1,
    );

    //Prepare the data to be sent
    //  data = {
    //   "amount": _amountController.text,
    //   "note": _noteController.text,
    //   "transaction_type": _isIncome ? "Credit" : "Debit",
    //   "category": _categoryController.text,
    //   "payment_method": _isIncome ? _paymentMethodController.text : "",
    //   "source": _isIncome ? _sourceController.text : "",
    // };

    try {
      final transaction_service = TransactionService();
      final response = await transaction_service.addTransaction(
        transaction_data,
      );

      if (!mounted) return;

      if (response) {
        Navigator.pop(context, true);
      } else {
        Navigator.pop(context, false);
      }
    } catch (e) {
      if (!mounted) return;
      print("Error adding transaction: $e");
      Navigator.pop(context, false);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    if (categoryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2️⃣ Loaded but empty → fallback message
    if (!categoryProvider.isLoading && categoryProvider.categories.isEmpty) {
      return const Center(child: Text("No categories available"));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("Income"),
                    selected: _isIncome,
                    onSelected: (val) => setState(() {
                      _isIncome = true;
                    }),
                    selectedColor: Colors.green,
                  ),
                  const SizedBox(width: 8.0),
                  ChoiceChip(
                    label: const Text("Expense"),
                    selected: !_isIncome,
                    onSelected: (val) => setState(() {
                      _isIncome = false;
                    }),
                    selectedColor: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _titleController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter title" : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  errorText: _amountError,

                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter amount" : null,
              ),
              const SizedBox(height: 16.0),

              DropdownButtonFormField<int>(
                initialValue: categoryProvider
                    .selectedCategoryId, // Set the initial selected value
                items: categoryProvider.categories
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e.id,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                onChanged: (newValue) {
                  // Handle category selection
                  categoryProvider.setSelectedCategoryId(newValue);
                },

                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? "Please enter category" : null,
              ),

              const SizedBox(height: 16.0),

              TextFormField(
                controller: _noteController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Enter Note (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16.0),
              //Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _addTransaction();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Processing Data")),
                      );
                    }
                  },
                  child: const Text("Save Transaction"),
                ),
              ),
            ],
          ),

          //Amount

          //Note
        ),
      ),
    );
  }
}
