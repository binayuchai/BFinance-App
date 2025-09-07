import 'package:flutter/material.dart';

class AddTransactionForm extends StatefulWidget {
  const AddTransactionForm({super.key});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  bool _isIncome = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _paymentMethodController =
      TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

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
