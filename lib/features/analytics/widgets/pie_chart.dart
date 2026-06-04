import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/core/utils/category_color.dart';
import 'package:bfinance/features/transaction/helper/transaction_summary.dart';
import 'package:intl/intl.dart';

class ExpenseDonutChart extends StatelessWidget {
  final Map<String, double> pieData;
  final TransactionSummary summary;
  const ExpenseDonutChart({
    super.key,
    required this.pieData,
    required this.summary,
  });
  // summary.getPieChartData.
  @override
  Widget build(BuildContext context) {
    if (pieData.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text("No expenses for this month")),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: 60,
                  sectionsSpace:
                      2, // Space between sections for better visibility
                  sections: pieData.entries.map((entry) {
                    String displayName = entry.key.length > 8
                        ? '${entry.key.substring(0, 8)}...'
                        : entry.key;
                    double percentage =
                        (entry.value / summary.totalExpenses) * 100;

                    return PieChartSectionData(
                      value: entry.value,
                      color: CategoryColorHelper.getColorForCategoryName(
                        entry.key,
                      ),
                      title: percentage > 5
                          ? '${percentage.toStringAsFixed(0)}%'
                          : '',
                      radius: 50,
                      titlePositionPercentageOffset: 0.6,
                    );
                  }).toList(),
                ),
              ),
              // Center text showing total expenses
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${summary.totalExpenses.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Expense',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16), // ⭐ spacing
        // Legend for categories
        Flexible(
          child: Wrap(
            spacing: 16, // Space between legend items
            runSpacing: 10, // Space between lines of legend
            alignment: WrapAlignment.center,
            children: pieData.entries.map((element) {
              double percentage = (element.value / summary.totalExpenses) * 100;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: CategoryColorHelper.getColorForCategoryName(
                        element.key,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${element.key} (${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
