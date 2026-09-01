import 'package:bfinance/features/analytics/widgets/weekly_chart.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/pie_chart.dart';
import 'widgets/monthly_chart.dart';
import 'package:bfinance/providers/currency_provider.dart';

class Analytics extends StatelessWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<TransactionProvider>().summary;
    final currencyCode = context.watch<CurrencyProvider>().currencyCode;

    // double totalExpense = summary.totalExpenses;
    final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final List<double> dailyExpenses = summary.getWeeklyExpenses;
    final List<double> monthlyExpenses = summary.getMonthlyExpenses;
    final List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    // This is where data comes from provider in real app

    print("Summary: ${summary.getPieChartData}");
    // Check if there's no data

    if (summary.totalExpenses == 0) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Finance Analytics"),
            bottom: const TabBar(
              tabs: [
                Tab(text: "Weekly"),
                Tab(text: "Monthly"),
              ],
            ),
          ),
          body: const Center(child: Text("No expense data available.")),
        ),
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text("Finance Analytics")),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            // Use ListView for better scrolling on smaller screens
            children: [
              // Text(
              //   "Total Income: \$${totalIncome.toStringAsFixed(2)}",
              //   style: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // Text(
              //   "Total Expense: \$${totalExpense.toStringAsFixed(2)}",
              //   style: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 20),
              SizedBox(
                // 200px for the donut plus space for the category legend.
                // height: 300,
                child: ExpenseDonutChart(
                  pieData: summary.getPieChartData,
                  currencyCode: currencyCode,
                ),
              ),

              const SizedBox(height: 20),
              TabBar(
                tabs: const [
                  Tab(text: "Weekly"),
                  Tab(text: "Monthly"),
                ],
              ),
              SizedBox(
                height: 300, //  height for better display of charts
                child: TabBarView(
                  children: [
                    WeeklyChart(
                      values: dailyExpenses,
                      labels: days,
                      currencyCode: currencyCode,
                    ),

                    MonthlyChart(
                      values: monthlyExpenses,
                      labels: months,
                      currencyCode: currencyCode,
                    ),
                    const SizedBox(
                      height: 20,
                    ), // bottom breathing room after last section
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
