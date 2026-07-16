import 'package:bfinance/providers/auth_provider.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:bfinance/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/navigation/core_navigation.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/category_provider.dart';
import 'package:bfinance/providers/currency_provider.dart';
import 'package:bfinance/providers/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add your providers here
        // without cascade — two lines

        // final provider = ThemeProvider();
        // provider.initialize();
        //shortcut for ChangeNotifierProvider(
        //   create: (_) => ThemeProvider()..initialize(),
        // )
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ), //  Holds & exposes category state; rebuilds UI on changes
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(),
        ), //  Holds & exposes transaction state; rebuilds UI on changes
        ChangeNotifierProvider(
          create: (_) => CurrencyProvider()..initialize(),
        ), //  Holds & exposes currency state; initializes on app start
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initialize(),
        ), //  Holds & exposes theme state; initializes on app start
      ],
      child: Consumer<ThemeProvider>(
        // The main use of Consumer is to rebuild only a specific  section of UI when a Provider changes like context.watch<ThemeProvider>() .
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'BFinance Manager',
            navigatorKey: navigatorKey, // Set the global navigator key
            initialRoute: '/home',
            theme: themeProvider
                .lightTheme, // Use the theme data from the provider
            darkTheme: themeProvider.darkTheme,
            themeMode:
                themeProvider.themeMode, // Use the theme mode from the provider
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
