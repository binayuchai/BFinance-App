import 'package:bfinance/core/validators/amount_validator.dart';
import 'package:bfinance/features/category/widgets/add_category.dart';
import 'package:bfinance/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:bfinance/features/transaction/models/transaction.dart';
import 'package:bfinance/features/category/widgets/category_grid.dart';
import 'package:bfinance/providers/currency_provider.dart';
// TOdo list
// make amount fields only accept digits upto Ensure that there are no more than 12 digits in total.

class EditTransactionForm extends StatefulWidget {
  final Transaction transactions; // receives exisiting transaction data
  const EditTransactionForm({super.key, required this.transactions});

  @override
  State<EditTransactionForm> createState() => _EditTransactionFormState();
}

class _EditTransactionFormState extends State<EditTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController
  _titleController; // Initialize in initState to prefill with existing data
  late final TextEditingController _amountController;
  late bool _isIncome;
  late final TextEditingController _noteController;
  bool isLoading = false;
  String? _amountError; // To hold validation error message for amount field
  String?
  _categoryError; // To hold validation error message for category selection
  String? titleError; // To hold validation error message for title field
  @override
  void initState() {
    super.initState();
    //Prefill with exisiting transaction data
    _titleController = TextEditingController(text: widget.transactions.title);
    _amountController = TextEditingController(
      text: widget.transactions.amount.toString(),
    );
    _isIncome = widget.transactions.isIncome;
    _noteController = TextEditingController(text: widget.transactions.note);

    //pre-select exisiting category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().setSelectedCategoryId(
        widget.transactions.categoryId,
      );
      context.read<CategoryProvider>().ensureLoaded(); //
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  Future<void> _openCreateCategoryScreen() async {
    final rootMessenger = ScaffoldMessenger.of(
      context,
    ); // Get the root ScaffoldMessenger
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCategory()),
    );
    if (result == true) {
      if (!mounted) return;
      // After returning, refresh the category list
      context.read<CategoryProvider>().fetchCategories();
      rootMessenger.showSnackBar(
        const SnackBar(content: Text("Category added successfully")),
      );
    }
  }

  Future<void> _saveEdit() async {
    setState(() {
      isLoading = true;
      _amountError = null; // Reset amount error before validation
    });
    try {
      //validate amount
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
            isLoading = false; // reset loading state on validation failure
          });
        }
        return;
      }

      final categoryProvider = context.read<CategoryProvider>();
      final currencyProvider = context.read<CurrencyProvider>();

      //validate category selection
      if (categoryProvider.selectedCategoryId == null) {
        setState(() {
          isLoading = false;
          _categoryError = "Please select a category";
        });

        return;
      }

      // Get the selected category object based on the selectedCategoryId
      final selectedCategory = categoryProvider.categories.firstWhere(
        (category) => category.id == categoryProvider.selectedCategoryId,
      );

      // Update the transaction object with new values
      final updatedTransaction = Transaction(
        amount: amount,
        title: _titleController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text.trim(),
        category: selectedCategory,
        date: widget.transactions.date, // Keep existing date
        time: widget.transactions.time, // Keep existing time
        categoryId: categoryProvider.selectedCategoryId!, // Update category ID
        id: widget.transactions.id, // Keep existing ID for API update
        currencyCode: currencyProvider.currencyCode,
      );
      // Call the provider to update the transaction
      final success = await context
          .read<TransactionProvider>()
          .editTransactionProvider(
            updatedTransaction,
            currencyProvider: currencyProvider,
          );
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction updated successfully")),
        );
        if (!mounted) return;
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update transaction. Please try again."),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16, // keyboard aware
      ),
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
                      categoryProvider.setSelectedCategoryId(
                        null,
                      ); // Reset category selection
                    }),
                    selectedColor: Colors.green,
                  ),
                  const SizedBox(width: 8.0),
                  ChoiceChip(
                    label: const Text("Expense"),
                    selected: !_isIncome,
                    onSelected: (val) => setState(() {
                      _isIncome = false;
                      categoryProvider.setSelectedCategoryId(
                        null,
                      ); // Reset category selection
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: "Amount",
                  errorText: _amountError,
                  helperText: "e.g. 2500.00",
                  suffixText: context.watch<CurrencyProvider>().currencyCode,

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
              // Show category error if exists
              if (_categoryError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _categoryError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
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
                  onPressed: isLoading
                      ? null // Disable button while loading
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(
                              context,
                            ).unfocus(); // dismiss keyboard first

                            ScaffoldMessenger.of(
                              context,
                            ).clearSnackBars(); //  clear queue first

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Updating transaction..."),
                              ),
                            );
                            await _saveEdit();
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
