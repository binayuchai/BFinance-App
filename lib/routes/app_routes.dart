import 'package:bfinance/features/auth/view/login.dart';
import 'package:bfinance/features/auth/view/register.dart';
import 'package:bfinance/features/dashboard/view/dashboard.dart';
import 'package:bfinance/navigation/bottom_nav.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = "/home";
  static const String register = "/register";
  static const String login = "/login";

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const BottomNav(),
    register: (context) => const RegisterScreen(),
    login: (context) => const LoginScreen(),
  };
}
