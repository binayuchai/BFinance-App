import 'package:bfinance/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/currency_provider.dart';
import 'package:bfinance/navigation/bottom_nav.dart';
import 'package:bfinance/features/dashboard/helper/section_header.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:bfinance/providers/transaction_provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          //Account Settings
          sectionHeader("Account Settings"),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text("Account"),
            subtitle: Text("Manage your account settings"),
            onTap: () {
              // Navigate to account settings page
              Navigator.pushNamed(context, AppRoutes.account);
            },
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text("Privacy & Security"),
            subtitle: Text("Manage your privacy and security settings"),
            onTap: () {
              // Navigate to privacy & security settings page
              Navigator.pushNamed(context, AppRoutes.privacy);
            },
          ),
          sectionHeader("App"),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
            subtitle: Text("Manage notification preferences"),
            onTap: () {
              // Navigate to notification settings page
            },
          ),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text("Appearance"),
            subtitle: Text("Customize the app's look and feel"),
            onTap: () {
              // Navigate to appearance settings page
              Navigator.pushNamed(context, AppRoutes.appearance);
            },
          ),
          //Preferences
          sectionHeader("Preferences"),
          ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text("Currency"),
            subtitle: Text("Select your preferred currency"),
            trailing: const Icon(Icons.chevron_right),

            onTap: () {
              // Show currency selection dialog
              showCurrencyPicker(
                context: context,
                showFlag: true,
                showCurrencyName: true,
                showCurrencyCode: true,
                onSelect: (Currency currency) async {
                  final String? error = await context
                      .read<CurrencyProvider>()
                      .setCurrency(currency.code);
                  if (!context.mounted) return;

                  await context.read<TransactionProvider>().convertAllAmount(
                    currencyProvider,
                  );
                  if (error == null) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Currency changed to ${currency.code}"),
                      ),
                    );
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to change currency: $error"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
