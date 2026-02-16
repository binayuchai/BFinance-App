import 'package:bfinance/providers/transaction_provider.dart';
import 'package:bfinance/utils/category_color.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class Analytics extends StatelessWidget {
  const Analytics({super.key});

  Widget buildLineChart(List<double> values, List<String> labels) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              values.length,
              (index) => FlSpot(index.toDouble(), values[index]),
            ),
            isCurved: true,
            barWidth: 3,
            color: Colors.blue,
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < labels.length) {
                  return Text(labels[index]);
                } else {
                  return const Text("");
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = 500;
    double totalExpense = 3000;
    final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final List<double> dailyExpenses = [500, 300, 400, 200, 600, 700, 800];
    final List<double> monthlyExpenses = [
      400,
      600,
      500,
      700,
      800,
      900,
      1000,
      1100,
      1200,
      1300,
      1400,
      1500,
    ];
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

    final summary = context.watch<TransactionProvider>().summary;
    print("Summary: ${summary.getPieChartData}");
    // Check if there's no data
    if (summary.getPieChartData.isEmpty) {
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
        appBar: AppBar(
          title: const Text("Finance Analytics"),
          bottom: TabBar(
            tabs: const [
              Tab(text: "Weekly"),
              Tab(text: "Monthly"),
            ],
          ),
        ),

        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Total Income: \$${totalIncome.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Total Expense: \$${totalExpense.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 40,

                      // You can add pie chart sections here
                      sections: summary.getPieChartData.entries.map((entry) {
                        // Truncate category name if too long
                        String displayName = entry.key.length > 8
                            ? '${entry.key.substring(0, 8)}...'
                            : entry.key;
                        double percentage =
                            (entry.value / summary.totalExpenses) * 100;

                        return PieChartSectionData(
                          value: entry.value, // Handle null values
                          color: CategoryColorHelper.getColorForCategoryName(
                            entry.key, // Use category ID for color mapping
                          ),
                          title:
                              '${displayName} (${percentage.toStringAsFixed(1)}%)', // Display truncated category name as title with percentage

                          radius: 70,
                        );
                        // PieChartSectionData(
                        //   value: totalExpense,
                        //   color: Colors.red,
                        //   title: 'Expense',
                        //   radius: 80,
                        // ),
                      }).toList(),
                    ),
                    // duration: Duration(milliseconds: 700), // Optional
                    // curve: Curves.easeInBack, // Optional
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: TabBarView(
                    children: [
                      buildLineChart(dailyExpenses, days),

                      buildLineChart(monthlyExpenses, months),
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
      ),
    );
  }
}
