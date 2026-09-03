import 'package:bfinance/core/utils/route_observer.dart';
import 'package:bfinance/providers/auth_provider.dart';
import 'package:bfinance/providers/connectivity_provider.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:bfinance/routes/app_routes.dart';
import 'package:bfinance/services/notification_service.dart';
import 'package:bfinance/widgets/offline_indicator.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/navigation/core_navigation.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/category_provider.dart';
import 'package:bfinance/providers/currency_provider.dart';
import 'package:bfinance/providers/theme_provider.dart';

void main() async {
  /// Initialize Flutter bindings before async operations
  /// Required when using await before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize notification service with timezone, permissions, etc.

  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _routeObserver = RouteTrackingObserver();

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
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..initialize(),
        ), //  Holds & exposes category state; rebuilds UI on changes
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..loadCachedTransactions(),
        ), //  Holds & exposes transaction state; rebuilds UI on changes
        ChangeNotifierProvider(
          create: (_) => CurrencyProvider()..initialize(),
        ), //  Holds & exposes currency state; initializes on app start
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..loadProfileFromCache(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initialize(),
        ), //  Holds & exposes theme state; initializes on app start
      ],
      child: Consumer<ThemeProvider>(
        // The main use of Consumer is to rebuild only a specific  section of UI when a Provider changes like context.watch<ThemeProvider>() .
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'BFinance Manager',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            initialRoute: AppRoutes.home,
            routes: AppRoutes.routes,
            navigatorObservers: [_routeObserver],
            theme: themeProvider
                .lightTheme, // Use the theme data from the provider
            darkTheme: themeProvider.darkTheme,
            themeMode:
                themeProvider.themeMode, // Use the theme mode from the provider
            builder: (context, child) {
              return ValueListenableBuilder<String?>(
                valueListenable: _routeObserver.currentRoute,
                builder: (context, route, _) {
                  final hideOnThisRoute =
                      route == null ||
                      AppRoutes.hideIndicatorOnRoutes.contains(route);
                  return Consumer<ConnectivityProvider>(
                    builder: (context, connectivity, _) {
                      final showBanner =
                          !hideOnThisRoute && connectivity.isOffline;
                      return Column(
                        children: [
                          SafeArea(
                            bottom: false,
                            child: OfflineIndicator(isOnline: !showBanner),
                          ),
                          Expanded(child: child ?? const SizedBox.shrink()),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
