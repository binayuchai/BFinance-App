import 'package:bfinance/features/app_shell/app_shell.dart';
import 'package:bfinance/features/auth/view/forgot_password.dart';
import 'package:bfinance/features/auth/view/login.dart';
import 'package:bfinance/features/auth/view/new-password.dart';
import 'package:bfinance/features/auth/view/register.dart';
import 'package:bfinance/features/auth/view/verify_otp.dart';
import 'package:bfinance/features/settings/account/account_screen.dart';
import 'package:bfinance/features/settings/notifications/notifications_screen.dart';
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
  static const String notification = "/notification";
  static const String forgotPassword = "/forgot-password";
  static const String verifyOtp = "/verify-otp";
  static const String newPassword = "/new-password";

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const SplashScreen(),
    register: (context) => const RegisterScreen(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const BottomNav(),
    app: (context) => const AppShell(),
    account: (context) => const AccountScreen(),
    appearance: (context) => const AppearanceScreen(),
    privacy: (context) => const PrivacyScreen(),
    notification: (context) => const NotificationsScreen(),
    forgotPassword: (context) => const ForgotPassword(),
    verifyOtp: (context) => const VerifyOtp(),
    newPassword: (context) => const NewPassword(),
  };

  //Routes that should not show Offline Indicator
  static const Set<String> hideIndicatorOnRoutes = {
    '/home',
    '/login',
    '/register',
    '/forgot-password',
    '/verify-otp',
    '/new-password',
  };

  //Generate route based on route name
  // Called whenever Navigator.pushName() is used

  static Route<dynamic> generateRoute(RouteSettings settings) {
    //look up the route builder
    final WidgetBuilder? builder = routes[settings.name];

    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    // If route not found, show error page
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
