import 'package:flutter/material.dart';
import 'package:bfinance/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/category_provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService api = ApiService();
  final storage = FlutterSecureStorage();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      print("Email: $email");
      print("Password: $password");

      try {
        // Call the login API
        final result = await api.loginUser(email, password);

        if (result.success) {
          if (!mounted) return;
          print("Login successful");
          final token = await api.getAccessToken();
          print("Login dashboard token : $token");
          context.read<CategoryProvider>().resetCategories(); // 👈
          await context.read<CategoryProvider>().fetchCategories();
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          // Show error message from backend
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.errorMessage ?? "Login failed. Please try again.",
              ),
            ),
          );
          print("Login failed: ${result.errorMessage}");
        }
      } catch (e) {
        // Handle API errors
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Network error: ${e.toString()}")),
        );
        print("Login error: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final message = ModalRoute.of(context)?.settings.arguments as String?;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.orange),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),

      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,

              child: Form(
                key: _formKey,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email Address",
                        hintText: "Enter your email",
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true, // Hides the password input
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        labelText: "Password",
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.blue,
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 60),
                    // ElevatedButton is used to submit the form
                    TextButton(
                      onPressed: _submit,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                      child: Text("Login"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Don't have an account?"),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/register',
                              );
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
