import 'dart:io';

import 'package:bfinance/features/settings/helper/section_label.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricAvailable =
      false; // Flag to check if biometric authentication is available

  bool _biometricEnabled =
      false; // Flag to check if biometric authentication is enabled
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    //check if biometric authentication is available on the device
    bool available = false;
    try {
      available = await _localAuth
          .canCheckBiometrics; // Check if the device supports biometric authentication
      final biometrics = await _localAuth
          .getAvailableBiometrics(); // Get the list of available biometric types (e.g., fingerprint, face recognition)
      available =
          available &&
          biometrics.isNotEmpty; // Check if there are any enrolled biometrics
    } on PlatformException {
      // Handle the error if needed
      available = false;
    }

    // load saved preference
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricAvailable = available;
      _biometricEnabled = prefs.getBool('biometric_lock') ?? false;
      _isLoading = false;
    });
  }

  // Toggle biometric authentication
  Future<void> _toggleBiometricAuthentication(bool value) async {
    if (value) {
      // authenticate before enabling biometric authentication
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason:
              'Confirm your identity to enable biometric authentication',
        );
        if (!authenticated) {
          // User failed to authenticate, do not enable biometric authentication
          return;
        }
      } on PlatformException {
        // hardware error - sensor unavailable or not enrolled,etc.
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Biometric authentication is not available on this device.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Save the preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_lock', value);
    setState(() {
      _biometricEnabled = value;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Biometric authentication enabled.'
              : 'Biometric authentication disabled.',
        ),
        backgroundColor: value ? Colors.green : Colors.red,
      ),
    );
  }

  // export data
  Future<void> _exportCSV() async {
    setState(() {
      _isExporting = true;
    });
    try {
      final transactions = context.read<TransactionProvider>().transactions;
      if (transactions.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No transactions to export.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final buffer = StringBuffer();

      // header
      buffer.writeln('Date,Type,Amount,Currency,Note');

      //rows
      for (final tx in transactions) {
        final date = tx.date.split('T').first; // format date as YYYY-MM-DD
        final type = tx.isIncome ? 'Income' : 'Expense';
        final amount = tx.amount.toStringAsFixed(2);
        final currency = tx.currencyCode;
        final note =
            tx.note?.replaceAll(',', ' ') ?? ''; // remove commas from note
        buffer.writeln('$date,$type,$amount,$currency,$note');
      }

      final fileName = 'bfinance_${DateTime.now().millisecondsSinceEpoch}.csv';
      final temporaryDirectory = await getTemporaryDirectory();
      final temporaryFile = File('${temporaryDirectory.path}/$fileName');
      await temporaryFile.writeAsString(buffer.toString());

      // This opens Android's system document picker or the iOS Files picker,
      // allowing the user to choose a local location and file name.
      final savedPath = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(sourceFilePath: temporaryFile.path),
      );

      if (!mounted || savedPath == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction export saved.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        children: [
          // Privacy & Security settings content goes here

          //biometric authentication
          const SectionLabel('Security'),
          SwitchListTile(
            secondary: Icon(
              Icons.fingerprint,
              color: !_biometricAvailable ? Colors.grey : null,
            ),
            title: Text(
              'Biometric Authentication',
              style: TextStyle(
                color: !_biometricAvailable ? Colors.grey : null,
              ),
            ),
            subtitle: Text(
              _biometricAvailable
                  ? 'Use fingerprint or face recognition to unlock the app'
                  : 'Biometric authentication is not available on this device',
            ),

            value: _biometricEnabled, // Replace with actual value from  state

            onChanged: _biometricAvailable
                ? _toggleBiometricAuthentication
                : null,
          ),

          // Export data
          const SectionLabel('Data'),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export transactions'),
            subtitle: const Text('Download all transactions as CSV'),
            trailing: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,

                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isExporting ? null : _exportCSV,
          ),
        ],
      ),
    );
  }
}
