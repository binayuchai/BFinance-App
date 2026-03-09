import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/utils/category_color.dart';
import 'package:bfinance/features/dashboard/helper/transaction_summary.dart';
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

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: 50,
              sectionsSpace: 2, // Space between sections for better visibility
              // You can add pie chart sections here
              sections: pieData.entries.map((entry) {
                // Truncate category name if too long
                String displayName = entry.key.length > 8
                    ? '${entry.key.substring(0, 8)}...'
                    : entry.key;
                double percentage = (entry.value / summary.totalExpenses) * 100;

                return PieChartSectionData(
                  value: entry.value, // Handle null values
                  color: CategoryColorHelper.getColorForCategoryName(
                    entry.key, // Use category ID for color mapping
                  ),
                  title: percentage > 5
                      ? '${percentage.toStringAsFixed(0)}%'
                      : '',

                  // title:
                  //     '${displayName} (${percentage.toStringAsFixed(1)}%)', // Display truncated category name as title with percentage
                  radius: 50,
                  titlePositionPercentageOffset:
                      0.6, // Adjust title position closer to the center
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

          // Center text showing total expenses
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${summary.totalExpenses.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Expense',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Add spacing below the chart
          // Legend for categories
          Wrap(
            spacing: 12, // Space between legend items
            runSpacing: 8, // Space between lines of legend
            alignment: WrapAlignment.center,
            children: pieData.entries.map((element) {
              double percentage = (element.value / summary.totalExpenses) * 100;
              return Row(
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
        ],
      ),
    );
  }
}





//  SizedBox(
//                   height: 200,
//                   child: PieChart(
//                     PieChartData(
//                       centerSpaceRadius: 40,

//                       // You can add pie chart sections here
//                       sections: summary.getPieChartData.entries.map((entry) {
//                         // Truncate category name if too long
//                         String displayName = entry.key.length > 8
//                             ? '${entry.key.substring(0, 8)}...'
//                             : entry.key;
//                         double percentage =
//                             (entry.value / summary.totalExpenses) * 100;

//                         return PieChartSectionData(
//                           value: entry.value, // Handle null values
//                           color: CategoryColorHelper.getColorForCategoryName(
//                             entry.key, // Use category ID for color mapping
//                           ),
//                           title:
//                               '${displayName} (${percentage.toStringAsFixed(1)}%)', // Display truncated category name as title with percentage

//                           radius: 70,
//                         );
//                         // PieChartSectionData(
//                         //   value: totalExpense,
//                         //   color: Colors.red,
//                         //   title: 'Expense',
//                         //   radius: 80,
//                         // ),
//                       }).toList(),
//                     ),
//                     // duration: Duration(milliseconds: 700), // Optional
//                     // curve: Curves.easeInBack, // Optional
//                   ),
//                 ),