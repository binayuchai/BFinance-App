import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // notification IDs - unique per notification type
  static const int _transactionReminderId = 1;
  static const int _budgetAlertId = 2;
  static const int _monthlySummaryId = 3;

  Future<void> initialize() async {
    //initialize timezone
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);

    //request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  //schedule daily transaction reminder
  Future<void> scheduleDailyReminder(int hour, int minute) async {
    // cancel existing first
    await cancelTransactionReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    //if time already passed today -> schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _transactionReminderId,
      scheduledDate: scheduled,
      title: 'Don\'t forget! 💰',
      body: 'Have you logged today\'s transactions?',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'transaction_reminder', // channel id
          'Transaction Reminders', // channel name
          channelDescription: 'Daily reminder to log transactions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }

  //cancel transaction reminder
  Future<void> cancelTransactionReminder() async {
    await _plugin.cancel(id: _transactionReminderId);
  }

  // show budget alert immediately
  Future<void> showBudgetAlert(
    String type,
    String name,
    double amount,
    double limitAmount,
    String currencyCode,
  ) async {
    final title = type == 'total'
        ? 'Monthly budget exceeded! ⚠️'
        : '$name budget exceeded! ⚠️';
    await _plugin.show(
      id: _budgetAlertId,
      title: title,
      body:
          'Spent $currencyCode ${amount.toStringAsFixed(0)} of  $currencyCode ${limitAmount.toStringAsFixed(0)} limit',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts', // channel id
          'Budget Alerts', // channel name
          channelDescription: 'Alerts when budget limit is reached',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  //schedule monthly summary - last day of month at 9AM
  Future<void> scheduleMonthlySummary() async {
    await cancelMonthlySummary();
    final now = tz.TZDateTime.now(tz.local);

    //last day of current month
    final lastDay = DateTime(now.year, now.month + 1, 0);
    var scheduled = tz.TZDateTime(
      tz.local,
      lastDay.year,
      lastDay.month,
      lastDay.day,
      9, // 9AM
      0,
    );

    if (scheduled.isBefore(now)) {
      //schedule for last day of next month
      final nextLastDay = DateTime(now.year, now.month + 2, 0);
      scheduled = tz.TZDateTime(
        tz.local,
        nextLastDay.year,
        nextLastDay.month,
        nextLastDay.day,
        9, // 9AM
        0,
      );
    }

    await _plugin.zonedSchedule(
      id: _monthlySummaryId,
      title: 'Monthly summary ready 📊',
      body: 'Check how you spent this month.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'monthly_summary', // channel id
          'Monthly Summary', // channel name
          channelDescription: 'Monthly spending report notification',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancel Monthly Summary
  Future<void> cancelMonthlySummary() async {
    await _plugin.cancel(id: _monthlySummaryId);
  }

  //cancel all
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
