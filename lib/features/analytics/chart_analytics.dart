import 'package:bfinance/features/analytics/widgets/weekly_chart.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/pie_chart.dart';
import 'widgets/monthly_chart.dart';

class Analytics extends StatelessWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<TransactionProvider>().summary;

    double totalExpense = summary.totalExpenses;
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
          child: Column(
            children: [
              // Text(
              //   "Total Income: \$${totalIncome.toStringAsFixed(2)}",
              //   style: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              Text(
                "Total Expense: \$${totalExpense.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                child: ExpenseDonutChart(
                  pieData: summary.getPieChartData,
                  summary: summary,
                ),
              ),

              const SizedBox(height: 20),
              TabBar(
                tabs: const [
                  Tab(text: "Weekly"),
                  Tab(text: "Monthly"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    WeeklyChart(values: dailyExpenses, labels: days),

                    MonthlyChart(values: monthlyExpenses, labels: months),
                  ],
                ),
              ),

              /* SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 6000,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1000,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < days.length) {
                                return Text(days[index]);
                              }
                              return const Text("");
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(dailyExpenses.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: dailyExpenses[index],
                              color: Colors.red,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                    duration: Duration(milliseconds: 1500), // Optional
                    curve: Curves.easeInBack, // Optional
                  ),
                ),  */
            ],
          ),
        ),
      ),
    );
  }
}
