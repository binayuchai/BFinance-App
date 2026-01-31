import 'package:flutter/material.dart';
import 'package:bfinance/services/api_service.dart' as api;
import 'package:flutter/rendering.dart';

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

      print("Navigating to dashboard");
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<bool> autologin() async {
    // Implement auto-login logic here
    try {
      final token = await api.ApiService().getAccessToken();
      print("Response tokenduring login: $token");

      if (token == null) {
        // Navigate to login
        return false;
      } else {
        // Navigate to dashboard
        return true;
      }
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
