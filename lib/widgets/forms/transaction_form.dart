import 'dart:async';

import 'package:bfinance/features/category/widgets/add_category.dart';
import 'package:bfinance/features/category/widgets/category_grid.dart';
import 'package:bfinance/features/transaction/models/transaction.dart';
import 'package:bfinance/providers/currency_provider.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/services/api_service.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:bfinance/providers/category_provider.dart';
import 'package:bfinance/core/validators/amount_validator.dart';

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

  String? _categoryError;

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
    final amount = AmountValidator.validateAndParse(_amountController.text, (
      error,
    ) {
      if (mounted) {
        setState(() {
          _amountError = error;
        });
      }
    });
    if (amount == null) {
      if (mounted) {
        //  ensure we are still in the widget context before updating state
        setState(() {
          _isLoadingTransaction =
              false; // reset loading state on validation failure
        });
      }
      return "";
    }

    final categoryProvider = context.read<CategoryProvider>();
    final currencyProvider = context.read<CurrencyProvider>();

    // Validate category selection
    if (categoryProvider.selectedCategoryId == null) {
      setState(() {
        _isLoadingTransaction = false; // reset on early return
        _categoryError = "Please select a category";
      });
      return "";
    }

    final selectedCategory = categoryProvider.categories.firstWhere(
      (cat) => cat.id == categoryProvider.selectedCategoryId,
    );

    final Transaction transactionData = Transaction(
      title: _titleController.text,
      date: DateTime.now().toString(),
      amount: amount,
      // type: _isIncome ? TransactionType.income : TransactionType.expense,
      time: DateTime.now().toString(),
      note: _noteController.text == "" ? null : _noteController.text,
      categoryId: categoryProvider.selectedCategoryId ?? 1,
      category: selectedCategory,
      currencyCode: currencyProvider.currencyCode,
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
    //  show SnackBar only after validation passes
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Saving transaction...")));
    }

    try {
      final response = await context
          .read<TransactionProvider>()
          .addTransactionProvider(
            transactionData,
            currencyProvider: currencyProvider,
          );

      if (response) {
        if (mounted) {
          setState(
            () => _isLoadingTransaction = false,
          ); // reset loading state on success
        }

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
      // ✅ if session expired, logout already happened
      if (e.toString().contains('No valid access token')) {
        return ""; // ✅ return null so Navigator.pop never runs
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
    final currencyProvider = context.watch<CurrencyProvider>();

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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: "Amount",
                        errorText: _amountError,
                        helperText: "e.g. 2500.00",
                        suffixText: currencyProvider.currencyCode,

                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Please enter amount" : null,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),

              const SizedBox(height: 16.0),

              // Category Dropdown
              CategoryGrid(
                categories: categoryProvider.categories,
                selectedCategoryId: categoryProvider.selectedCategoryId,
                onCategorySelected: (id) {
                  categoryProvider.setSelectedCategoryId(id);
                  setState(() {
                    _categoryError = null; // Clear error on selection
                  });
                },
                onAddCategory: () => _openCreateCategoryScreen(),
                isIncome: _isIncome,
              ),
              // Show category error if exists
              if (_categoryError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _categoryError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
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
                            FocusScope.of(
                              context,
                            ).unfocus(); // dismiss keyboard first

                            final result = await _addTransaction();
                            if (!mounted) return;
                            if (result == "") return;

                            Navigator.pop(context, result ?? "success");
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
