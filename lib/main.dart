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
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  /// Initialize and Configure Sentry to track errors and crashes
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://9288d8be4ff4d20c8029ff49ecce56bc@o4512100552081408.ingest.us.sentry.io/4512100553850880';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () {
      /// Initialize Flutter bindings before async operations
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        Sentry.captureException(details.exception, stackTrace: details.stack);
      };
      //  the UI renders immediately, no matter what.
      runApp(const MyApp());
    },
  );


}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _routeObserver = RouteTrackingObserver();

  @override
  void initState() {
    super.initState();
    // Non-critical startup work happens AFTER the first frame is drawn,
    // so a hang or failure here can never block the UI from appearing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBackgroundServices();
    });
  }

  Future<void> _initBackgroundServices() async{
    await NotificationService().initialize();
    debugPrint('NotificationService init attempted');


  }
  

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
          create: (_) => TransactionProvider(),
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
