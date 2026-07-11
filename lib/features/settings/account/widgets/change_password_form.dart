import 'package:bfinance/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  //Per-field errors
  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //local validation before sending to backend
  bool _validate() {
    setState(() {
      _oldPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });
    bool valid = true;
    if (_oldPasswordController.text.trim().isEmpty) {
      setState(() {
        _oldPasswordError = "Current password is required";
      });
      valid = false;
    }
    if (_newPasswordController.text.trim().isEmpty) {
      setState(() {
        _newPasswordError = "New password is required";
      });
      valid = false;
    } else if (_newPasswordController.text.trim().length < 8) {
      setState(() {
        _newPasswordError = "New password must be at least 8 characters";
      });
      valid = false;
    }
    if (_confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        _confirmPasswordError = "Please confirm your new password";
      });
      valid = false;
    } else if (_confirmPasswordController.text.trim() !=
        _newPasswordController.text.trim()) {
      setState(() {
        _confirmPasswordError = "Passwords do not match";
      });
      valid = false;
    }
    return valid;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() {
      _isLoading = true;
    });
    final result = await context.read<AuthProvider>().changePassword(
      oldPassword: _oldPasswordController.text,
      password: _newPasswordController.text,
      password2: _confirmPasswordController.text,
    );
    if (!mounted) return;
    if (result.success) {
      Navigator.pop(context); // Close the bottom sheet on success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.successMessage ?? "Password changed successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        final error = result.errorMessage ?? "An error occurred";
        // Route the error message to the appropriate field based on its content
        if (error.toLowerCase().contains('current') ||
            error.toLowerCase().contains('old') ||
            error.toLowerCase().contains('incorrect')) {
          _oldPasswordError = error;
        } else if (error.toLowerCase().contains("new password")) {
          _newPasswordError = error;
        } else if (error.toLowerCase().contains('match') ||
            error.toLowerCase().contains('confirm')) {
          _confirmPasswordError = error;
        } else {
          // If the error doesn't match any specific field, show a general error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
        // _oldPasswordError = result.errorMessage;
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
        mainAxisSize: MainAxisSize
            .min, // With this, Column only takes as much height as its children needed
        children: [
          // Handle to indicate draggable sheet
          Center(
            child: Container(
              width: 36, // short width - pill shape

              height: 5, // short height - pill shape
              margin: const EdgeInsets.only(
                bottom: 16,
              ), //space below the handle
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const Text(
            "Change Password",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // old password field
          TextField(
            controller: _oldPasswordController,
            obscureText: _obscureOld,

            decoration: InputDecoration(
              labelText: "Current Password",
              errorText: _oldPasswordError,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureOld ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureOld = !_obscureOld;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // new password field
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNew,

            decoration: InputDecoration(
              labelText: "New Password",
              errorText: _newPasswordError,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNew = !_obscureNew;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // confirm new password field
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,

            decoration: InputDecoration(
              labelText: "Confirm new password",
              errorText: _confirmPasswordError,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Update Password"),
            ),
          ),
        ],
      ),
    );
  }
}
