import 'package:bfinance/features/auth/view/login.dart';
import 'package:bfinance/features/auth/view/register.dart';
import 'package:bfinance/features/splash/splash_screen.dart';
import 'package:bfinance/navigation/bottom_nav.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = "/home";
  static const String register = "/register";
  static const String login = "/login";
  static const String dashboard = "/dashboard";

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const SplashScreen(),
    register: (context) => const RegisterScreen(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const BottomNav(),
  };
}
