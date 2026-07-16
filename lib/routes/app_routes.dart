import 'package:bfinance/features/app_shell/app_shell.dart';
import 'package:bfinance/features/auth/view/login.dart';
import 'package:bfinance/features/auth/view/register.dart';
import 'package:bfinance/features/settings/account/account_screen.dart';
import 'package:bfinance/features/settings/privacy/privacy_screen.dart';
import 'package:bfinance/features/splash/splash_screen.dart';
import 'package:bfinance/navigation/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/features/settings/appearance/appearance_screen.dart';

class AppRoutes {
  static const String home = "/home";
  static const String register = "/register";
  static const String login = "/login";
  static const String dashboard = "/dashboard";
  static const String app = "/app";
  static const String account = "/account";
  static const String appearance = "/appearance";
  static const String privacy = "/privacy";

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const SplashScreen(),
    register: (context) => const RegisterScreen(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const BottomNav(),
    app: (context) => const AppShell(),
    account: (context) => const AccountScreen(),
    appearance: (context) => const AppearanceScreen(),
    privacy: (context) => const PrivacyScreen(),
  };
}
