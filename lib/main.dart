import 'package:bfinance/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/navigation/core_navigation.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/category_provider.dart';

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
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ), //  Holds & exposes category state; rebuilds UI on changes
      ],
      child: MaterialApp(
        title: 'BFinance Manager',
        navigatorKey: navigatorKey, // Set the global navigator key
        initialRoute: '/home',
        theme: ThemeData(fontFamily: 'Poppins'),
        routes: AppRoutes.routes,
      ),
    );
  }
}
