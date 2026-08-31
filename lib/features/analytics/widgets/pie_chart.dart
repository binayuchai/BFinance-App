import 'package:bfinance/features/analytics/helper/format_currency.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/core/utils/category_color.dart';

class ExpenseDonutChart extends StatelessWidget {
  final Map<String, double> pieData;
  final String currencyCode;
  const ExpenseDonutChart({
    super.key,
    required this.pieData,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // fl_chart cannot render a meaningful pie when every value is zero or
    // invalid. Filter those values before building sections and the legend.
    final entries = pieData.entries
        .where((entry) => entry.value.isFinite && entry.value > 0)
        .toList();
    final totalExpenses = entries.fold<double>(
      0,
      (total, entry) => total + entry.value,
    );

    if (entries.isEmpty || totalExpenses <= 0) {
      return const Center(child: Text('No expenses for this month'));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
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
                  sections: entries.map((entry) {
                    final percentage = (entry.value / totalExpenses) * 100;

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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        ChartHelper.formatCurrency(totalExpenses, currencyCode),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),

                    Text(
                      'Total Expense',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16), // ⭐ spacing
        // Legend for categories
        Wrap(
          spacing: 16, // Space between legend items
          runSpacing: 10, // Space between lines of legend
          alignment: WrapAlignment.center,
          children: entries.map((element) {
            final percentage = (element.value / totalExpenses) * 100;
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
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
