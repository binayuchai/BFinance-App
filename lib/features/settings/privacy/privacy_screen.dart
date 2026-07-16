import 'package:bfinance/features/settings/helper/section_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
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
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                : null,
            onTap: null,
          ),
        ],
      ),
    );
  }
}
