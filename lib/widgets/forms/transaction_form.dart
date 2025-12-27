import 'dart:async';
import 'dart:convert';

import 'package:bfinance/features/dashboard/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bfinance/services/api_service.dart' as api;
import 'package:bfinance/services/transaction_service.dart';

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
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _paymentMethodController =
      TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  // Implement the logic to add transaction to the database
  final String apiUrl = 'http://127.0.0.1:8000/api';
  Future<void> _addTransaction() async {
    final api_service = api.ApiService();
    final Transaction transaction_data = Transaction(
      id: null,
      title: _titleController.text,
      date: DateTime.now().toString(),
      amount: double.parse(_amountController.text),
      type: _isIncome ? TransactionType.income : TransactionType.expense,
      time: DateTime.now().toString(),
      note: _noteController.text == "" ? null : _noteController.text,
      
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction added successfully")),
        );
        Navigator.pop(context);
      } else {
        print("Failed to add transaction");
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add transaction")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print("Error adding transaction: $e");
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error adding transaction")));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter amount" : null,
              ),
              const SizedBox(height: 16.0),

              if (_isIncome)
                TextFormField(
                  controller: _sourceController,
                  decoration: const InputDecoration(
                    labelText: "Source",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter source" : null,
                )
              else
                Column(
                  children: [
                    TextFormField(
                      controller: _categoryController,

                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Please enter category" : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _paymentMethodController,
                      decoration: const InputDecoration(
                        labelText: "Payment Method",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Please enter payment method" : null,
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _noteController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Note",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter note" : null,
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
