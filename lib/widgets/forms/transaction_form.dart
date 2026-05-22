import 'dart:async';

import 'package:bfinance/features/category/widgets/add_category.dart';
import 'package:bfinance/features/category/widgets/category_grid.dart';
import 'package:bfinance/features/transaction/models/transaction.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/services/api_service.dart';

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
  bool _isLoadingTransaction = false;

  //Defining the Error variable
  String? _amountError;

  //Push to create category screen

  Future<void> _openCreateCategoryScreen() async {
    // Implement navigation to create category screen

    // Capture the context of the root ScaffoldMessenger

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCategory(),
      ), // Navigate to the AddCategory screen
    );
    if (result == true) {
      if (!mounted) return;

      // Refresh categories if a new one was added
      context.read<CategoryProvider>().fetchCategories();
    }
  }

  // Implement the logic to add transaction to the database
  Future<String?> _addTransaction() async {
    setState(() {
      _amountError = null;
      _isLoadingTransaction = true;
    });
    //Basic validation
    double? amount; // Declare amount variable

    try {
      amount = double.parse(_amountController.text);
    } catch (e) {
      print("Invalid amount format: $e");
      setState(() {
        _amountError = "Please enter a valid number for amount";
        _isLoadingTransaction = false; // reset on early return
      });
      return "Please enter a valid number for amount";
    }

    final categoryProvider = context.read<CategoryProvider>();

    if (categoryProvider.selectedCategoryId == null) {
      setState(() {
        _isLoadingTransaction = false; // reset on early return
      });
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return "Please select a category";
    }
    final selectedCategory = categoryProvider.categories.firstWhere(
      (cat) => cat.id == categoryProvider.selectedCategoryId,
    );

    final Transaction transactionData = Transaction(
      id: null,
      title: _titleController.text,
      date: DateTime.now().toString(),
      amount: amount,
      // type: _isIncome ? TransactionType.income : TransactionType.expense,
      time: DateTime.now().toString(),
      note: _noteController.text == "" ? null : _noteController.text,
      categoryId: categoryProvider.selectedCategoryId ?? 1,
      category: selectedCategory,
      // category: selectedCategory,
      // categoryId: selectedCategory.id!,
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
      final response = await context
          .read<TransactionProvider>()
          .addTransactionProvider(transactionData);

      if (response) {
        if (mounted) {
          setState(
            () => _isLoadingTransaction = false,
          ); // reset loading state on success
        }
        await Future.delayed(const Duration(milliseconds: 900));
        // Navigator.pop(context, true);
        return null;
      } else {
        if (mounted) {
          setState(() => _isLoadingTransaction = false);
        } // reset loading state on failure
        return "Failed to add transaction. Please try again."; // Navigator.pop(context, false);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _isLoadingTransaction = false,
        ); // reset loading state on error
      }
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("Error: $e")));
      // return "An error occurred while adding the transaction. Please try again.";
      return "Network error: $e";
      // Navigator.pop(context, false);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();

      categoryProvider.setSelectedCategoryId(null);

      categoryProvider.ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    if (categoryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // // 2️⃣ Loaded but empty → show prompt to load defaults
    // if (!categoryProvider.isLoading && categoryProvider.categories.isEmpty) {
    //   return Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         const Icon(Icons.category_outlined, size: 48, color: Colors.grey),
    //         const SizedBox(height: 16),
    //         const Text("No categories found",
    //             style: TextStyle(fontWeight: FontWeight.bold)),
    //         const Padding(
    //           padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
    //           child: Text(
    //             "You need at least one category to add a transaction. Would you like to load our recommended presets?",
    //             textAlign: TextAlign.center,
    //             style: TextStyle(color: Colors.grey),
    //           ),
    //         ),
    //         const SizedBox(height: 16),
    //         ElevatedButton.icon(
    //           onPressed: () => categoryProvider.seedDefaultCategories(),
    //           icon: const Icon(Icons.auto_awesome),
    //           label: const Text("Load Preset Categories"),
    //         ),
    //         TextButton(
    //           onPressed: () => _openCreateCategoryScreen(),
    //           child: const Text("Create Custom Category"),
    //         ),
    //       ],
    //     ),
    //   );
    // }
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

              // Category Dropdown
              CategoryGrid(
                categories: categoryProvider.categories,
                selectedCategoryId: categoryProvider.selectedCategoryId,
                onCategorySelected: categoryProvider.setSelectedCategoryId,
                onAddCategory: () => _openCreateCategoryScreen(),
                isIncome: _isIncome,
              ),

              // DropdownButtonFormField<int>(
              //   initialValue: categoryProvider
              //       .selectedCategoryId, // Set the initial selected value
              //   items: categoryProvider.categories
              //       .map(
              //         (e) => DropdownMenuItem<int>(
              //           value: e.id,
              //           child: Text(e.name),
              //         ),
              //       )
              //       .toList(),
              //   onChanged: (newValue) {
              //     // Handle category selection
              //     categoryProvider.setSelectedCategoryId(newValue);
              //   },

              //   decoration: const InputDecoration(
              //     labelText: "Category",
              //     border: OutlineInputBorder(),
              //   ),
              //   validator: (value) =>
              //       value == null ? "Please enter category" : null,
              // ),
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
                  onPressed: _isLoadingTransaction
                      ? null // Disable button while loading
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final result = await _addTransaction();
                            if (!mounted) return;
                            Navigator.pop(context, result ?? "success");
                          }
                        },
                  child: _isLoadingTransaction
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Transaction"),
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
