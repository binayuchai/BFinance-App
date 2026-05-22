import 'package:bfinance/features/analytics/chart_analytics.dart';
import 'package:bfinance/features/category/category.dart';
import 'package:bfinance/features/dashboard/view/dashboard.dart';
import 'package:bfinance/features/dashboard/view/widgets/settings.dart';
import 'package:bfinance/features/dashboard/view/widgets/transaction.dart';
import 'package:bfinance/providers/category_provider.dart';

import 'package:bfinance/widgets/forms/transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/services/api_service.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardWidget(),
    const TransactionPage(),

    const Analytics(), // Placeholder for Analytics

    const Category(),
    const Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Transactions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Analytics",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Category",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final categoryProvider = context.read<CategoryProvider>();
          // Ensure categories are loaded before adding a transaction
          await categoryProvider.ensureLoaded();

          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);

          if (categoryProvider.categories.isEmpty) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                  "Please add a category before adding transactions",
                ),
              ),
            );
            //Return to category page
            setState(() {
              _selectedIndex = 4;
            });
            return;
          }

          final result = await showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: AddTransactionForm(),
            ),
          );
          //Checking token expiration and refreshing if needed before snackbar shows up
          final token = await ApiService().getAccessToken();

          if (!mounted) return;
          if (token == null) return;
          messenger
              .clearSnackBars(); // Clear any existing snackbars before showing new one
          if (result == null) {
            // User dismissed the form without adding a transaction
            return;
          } else if (result == "success") {
            messenger.showSnackBar(
              const SnackBar(content: Text("Transaction added successfully")),
            );
            // Refresh transactions
            // context.read<TransactionProvider>().fetchTransactions();
          } else {
            messenger.showSnackBar(SnackBar(content: Text(result)));
          }
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
