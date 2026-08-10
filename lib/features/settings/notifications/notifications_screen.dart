import 'package:bfinance/features/category/data/models/category.dart';
import 'package:bfinance/features/settings/helper/section_label.dart';
import 'package:bfinance/providers/category_provider.dart';
import 'package:bfinance/providers/currency_provider.dart';
import 'package:bfinance/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // notification preferences
  bool _pushNotifications = true;
  bool _transactionReminders = false;
  bool _budgetAlerts = false;
  bool _monthlySummary = true;
  bool _isLoading = true;
  double _totalBudgetLimit = 0.0;
  String _budgetCurrencyCode = 'USD';
  Map<int, double> _categoryLimits = {}; //categoryId → limit

  // reminder time
  TimeOfDay _reminderTime = const TimeOfDay(
    hour: 20,
    minute: 0,
  ); // 8:00 PM default

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // load Preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final currencyProvider = context.read<CurrencyProvider>();
    final currentCurrency = currencyProvider.currencyCode;
    final savedAmount = prefs.getDouble('notif_budget_limit');
    final savedCurrency =
        prefs.getString('notif_budget_currency') ?? currentCurrency;

    double loadedBudget;
    String loadedCurrency;

    if (savedAmount == null) {
      loadedBudget = await currencyProvider.convertAmount(1000, 'USD');
      loadedCurrency = currentCurrency;
    } else if (savedCurrency == currentCurrency) {
      loadedBudget = savedAmount;
      loadedCurrency = currentCurrency;
    } else {
      loadedBudget = await currencyProvider.convertAmount(
        savedAmount,
        savedCurrency,
      );
      loadedCurrency = currentCurrency;
    }

    setState(() {
      _pushNotifications = prefs.getBool('notif_push') ?? true;
      _transactionReminders =
          prefs.getBool('notif_transaction_reminders') ?? false;
      _monthlySummary = prefs.getBool('notif_monthly_summary') ?? true;
      _budgetAlerts = prefs.getBool('notif_budget_alerts') ?? false;

      // load saved reminder time
      final hour = prefs.getInt('notif_reminder_hour') ?? 20;
      final minute = prefs.getInt('notif_reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _totalBudgetLimit = loadedBudget;
      _budgetCurrencyCode = loadedCurrency;
      _isLoading = false;
    });

    //load category limis
    if (!mounted) return;

    final categories = context.read<CategoryProvider>().categories;
    final Map<int, double> limits = {};
    for (final cat in categories) {
      if (cat.type == CategoryType.expense && cat.id != null) {
        final limit = prefs.getDouble('notif_budget_category_${cat.id}');
        if (limit != null) limits[cat.id!] = limit;
      }
    }
    setState(() => _categoryLimits = limits);
  }

  // save preference
  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  //Function to pick reminder time
  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: 'Select reminder time',
    );
    if (picked == null) return;
    setState(() {
      _reminderTime = picked;
    });

    //save to prefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_reminder_hour', picked.hour);
    await prefs.setInt('notif_reminder_minute', picked.minute);

    //reschedule with new time
    if (_transactionReminders) {
      await NotificationService().scheduleDailyReminder(
        picked.hour,
        picked.minute,
      );
    }
  }

  // format time
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod; // it format to 12 hours(like 12:12AM,5:00PM)
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute:$period';
  }

  Future<void> _syncBudgetToCurrentCurrency() async {
    if (!mounted) return;

    final currencyProvider = context.read<CurrencyProvider>();
    final targetCurrency = currencyProvider.currencyCode;

    // if currency is same or budget is in (-value or less than 0) , no need to convert
    if (_budgetCurrencyCode == targetCurrency || _totalBudgetLimit <= 0) return;

    final converted = await currencyProvider.convertAmount(
      _totalBudgetLimit,
      _budgetCurrencyCode,
    );

    if (!mounted) return;

    setState(() {
      _totalBudgetLimit = converted;
      _budgetCurrencyCode = targetCurrency;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('notif_budget_limit', converted);
    await prefs.setString('notif_budget_currency', targetCurrency);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currencyCode = context.read<CurrencyProvider>().currencyCode;
    // only call the function if currency has changed and budget is real (in positive)
    if (_budgetCurrencyCode != currencyCode && _totalBudgetLimit > 0) {
      _syncBudgetToCurrentCurrency();
    }
  }

  //showing Total Limit Dialog
  Future<void> _showTotalLimitDialog() async {
    final ctrl = TextEditingController(
      text: _totalBudgetLimit.toStringAsFixed(0),
    );
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Total monthly limit'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monthly limit',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(ctrl.text);
              if (value == null || value <= 0) return;
              final currencyCode = context
                  .read<CurrencyProvider>()
                  .currencyCode;
              setState(() {
                _totalBudgetLimit = value;
                _budgetCurrencyCode = currencyCode;
              });

              final prefs = await SharedPreferences.getInstance();
              await prefs.setDouble('notif_budget_limit', value);
              await prefs.setString('notif_budget_currency', currencyCode);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  //Dialog to show category limit Dialog
  Future<void> _showCategoryLimitDialog(Category category) async {
    final existing = _categoryLimits[category.id];
    final ctrl = TextEditingController(
      text: existing?.toStringAsFixed(0) ?? '',
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${category.name} limit'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '${category.name} monthly limit',
            hintText: 'Leave empty to remove limit',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          //remove limit option
          if (existing != null)
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('notif_budget_category_${category.id}');
                setState(() => _categoryLimits.remove(category.id));
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text(
                'Remove limit',
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(ctrl.text);
              if (value == null || value <= 0) return;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setDouble(
                'notif_budget_category_${category.id}',
                value,
              );
              setState(() => _categoryLimits[category.id!] = value);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = context
        .watch<CategoryProvider>()
        .categories
        .where((c) => c.type == CategoryType.expense)
        .toList();
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView(
        children: [
          // General
          const SectionLabel('General'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive app notifications'),
            value: _pushNotifications,
            onChanged: (value) async {
              setState(() => _pushNotifications = value);
              _savePref('notif_push', value);

              // disable all other if push notification turned off
              if (!value) {
                await NotificationService().cancelAll();
                setState(() {
                  _transactionReminders = false;
                  _monthlySummary = false;
                  _budgetAlerts = false;
                });
                _savePref('notif_transaction_reminders', false);
                _savePref('notif_monthly_summary', false);
                _savePref('notif_budget_alerts', false);
              }
            },
          ),

          //reminders
          const SectionLabel('Reminders'),
          SwitchListTile(
            secondary: Icon(
              Icons.receipt_outlined,
              color:
                  !_pushNotifications // if pushNotification is true, turn to default else, cannot
                  ? Theme.of(context).colorScheme.outline
                  : null,
            ),
            title: Text(
              'Transaction Reminders',
              style: TextStyle(
                color: !_pushNotifications
                    ? Theme.of(context).colorScheme.outline
                    : null,
              ),
            ),
            subtitle: Text(
              'Daily reminder to log transactions',
              style: TextStyle(
                color: !_pushNotifications
                    ? Theme.of(context).colorScheme.outline
                    : null,
              ),
            ),
            value: _transactionReminders,
            onChanged: _pushNotifications
                ? (value) async {
                    setState(() {
                      _transactionReminders = value;
                    });
                    _savePref('notif_transaction_reminders', value);
                    if (value) {
                      //schedule with saved time
                      await NotificationService().scheduleDailyReminder(
                        _reminderTime.hour,
                        _reminderTime.minute,
                      );
                    } else {
                      //cancel
                      await NotificationService().cancelTransactionReminder();
                    }
                  }
                : null,
          ),

          // reminder time picker - only show if reminders enabled
          if (_transactionReminders && _pushNotifications)
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Reminder time'),
              subtitle: const Text('When to send daily reminder'),
              trailing: TextButton(
                onPressed: _pickReminderTime,
                child: Text(
                  _formatTime(_reminderTime),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          SwitchListTile(
            secondary: Icon(
              Icons.bar_chart_outlined,
              color: !_pushNotifications
                  ? Theme.of(context).colorScheme.outline
                  : null,
            ),
            title: Text(
              'Monthly Summary',
              style: TextStyle(
                color: !_pushNotifications
                    ? Theme.of(context).colorScheme.outline
                    : null,
              ),
            ),
            subtitle: Text(
              'Monthly spending report',
              style: TextStyle(
                color: !_pushNotifications
                    ? Theme.of(context).colorScheme.outline
                    : null,
              ),
            ),
            value: _monthlySummary,
            onChanged: _pushNotifications
                ? (value) async {
                    setState(() {
                      _monthlySummary = value;
                    });
                    _savePref('notif_monthly_summary', value);
                    if (value) {
                      await NotificationService().scheduleMonthlySummary();
                    } else {
                      await NotificationService().cancelMonthlySummary();
                    }
                  }
                : null,
          ),

          //alerts
          const SectionLabel('Alerts'),
          SwitchListTile(
            secondary: Icon(
              Icons.warning_amber_outlined,
              color: !_pushNotifications
                  ? Theme.of(context).colorScheme.outline
                  : null,
            ),
            title: Text(
              'Budgets Alerts',
              style: TextStyle(
                color: !_pushNotifications
                    ? Theme.of(context).colorScheme.outline
                    : null,
              ),
            ),
            subtitle: Text(
              'Alert when budget limit is reached',
              style: TextStyle(
                color: !_pushNotifications
                    ? Theme.of(context).colorScheme.outline
                    : null,
              ),
            ),

            value: _budgetAlerts,
            onChanged: _pushNotifications
                ? (value) {
                    setState(() => _budgetAlerts = value);
                    _savePref('notif_budget_alerts', value);
                  }
                : null,
          ),

          //show limits only when budget alerts enabled
          if (_budgetAlerts && _pushNotifications) ...[
            //the spread operator ... is used to insert the contents of a collection into another collection.

            //total monthly limit
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Total monthly limit'),
              subtitle: const Text('Alert when total expenses exceed this'),
              trailing: TextButton(
                onPressed: _showTotalLimitDialog,
                child: Text(
                  '$_budgetCurrencyCode ${_totalBudgetLimit.toStringAsFixed(0)}',
                ),
              ),
            ),

            //category limits
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Category limits',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            ...expenseCategories.map(
              (category) => ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(category.name),
                trailing: TextButton(
                  onPressed: () => _showCategoryLimitDialog(category),
                  child: Text(
                    _categoryLimits.containsKey(category.id)
                        ? '$_budgetCurrencyCode ${_categoryLimits[category.id]!.toStringAsFixed(0)}'
                        : 'Set limit',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
