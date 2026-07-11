import 'package:bfinance/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditNameSheet extends StatefulWidget {
  const EditNameSheet({super.key});

  @override
  State<EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<EditNameSheet> {
  late TextEditingController _name;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    //prefill with current name
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name ?? "");
  }

  Future<void> _save() async {
    //checking whether empty or not
    if (_name.text.trim().isEmpty) {
      setState(() => _error = "Please enter your name.");
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await context.read<AuthProvider>().updateName(
      _name.text.trim(),
    );
    if (!mounted) return;
    if (result.success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.successMessage ?? "Name updated successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      //show error under field
      setState(() {
        _isLoading = false;
        _error = result.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            "Edit Name",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          //name field
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Name",
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          //Save Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _save,

              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}
