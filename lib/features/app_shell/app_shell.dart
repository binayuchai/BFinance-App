import 'package:bfinance/navigation/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/category_provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    // Load categories when the app shell is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const BottomNav();
  }
}
