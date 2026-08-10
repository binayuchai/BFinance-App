import 'package:flutter/material.dart';
import 'package:bfinance/services/api_service.dart' as api;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    final checkLogin =
        autologin(); // Call autologin and store the Future returns  = Future<bool>

    final result = await Future.wait(
      [Future.delayed(const Duration(seconds: 2)), checkLogin],
    ); // Wait for both the delay and the login check to complete autologin() and returns bool of arrays[null,bool]
    if (result[1] == true) {
      if (!mounted) return;

      //after valid token logged in - check biometric to access dashboard
      final prefs = await SharedPreferences.getInstance();
      final biometricEnabled = prefs.getBool('biometric_lock') ?? false;

      if (biometricEnabled) {
        // show biometric lock
        try {
          final authenticated = await LocalAuthentication().authenticate(
            localizedReason: 'Authenticate to access BFinance',
          );
          if (!mounted) return;
          if (authenticated) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            // user cancelled - show login
            Navigator.pushReplacementNamed(context, '/login');
          }
        } on PlatformException {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // go straight to app

        print("Navigating to dashboard");
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      if (!mounted) return;
      print("No token found, navigating to login");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<bool> autologin() async {
    // Implement auto-login logic here
    try {
      //check if we cached profile(offline access)
      final prefs = await SharedPreferences.getInstance();
      final cachedProfile = prefs.getString('cached_profile');
      if (cachedProfile != null) {
        debugPrint("Cached profile found: $cachedProfile");

        // Load the cached profile data if needed for offline access or display
        return true;
      }
      // If no cached profile, check for a valid token(online access)
      final token = await api.ApiService().getAccessToken();
      debugPrint("Response tokenduring login: $token");

      if (token != null) {
        // Navigate to login
        return true;
      }
      return false;
    } catch (e) {
      _showError(e.toString());
      return false;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo/bfinance_logo.png",
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
