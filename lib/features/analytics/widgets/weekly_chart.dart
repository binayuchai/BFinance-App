import 'package:bfinance/features/analytics/helper/format_currency.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  const WeeklyChart({super.key, required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: true),

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
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    ChartHelper.formatCurrency(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),

          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),

          barGroups: List.generate(values.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index] < 0 ? 0 : values[index],
                  color: Colors.blue,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}



// Old code for reference:
  // Widget buildWeeklyBarChart(List<double> values, List<String> labels) {
  //   return BarChart(
  //     BarChartData(
  //       alignment: BarChartAlignment.spaceAround,
  //       barTouchData: BarTouchData(enabled: true),

  //       titlesData: FlTitlesData(
  //         bottomTitles: AxisTitles(
  //           sideTitles: SideTitles(
  //             showTitles: true,
  //             getTitlesWidget: (value, meta) {
  //               int index = value.toInt();
  //               if (index < labels.length) {
  //                 return Text(labels[index]);
  //               } else {
  //                 return const Text("");
  //               }
  //             },
  //           ),
  //         ),
  //         leftTitles: AxisTitles(
  //           sideTitles: SideTitles(
  //             showTitles: true,
  //             getTitlesWidget: (value, meta) {
  //               return Text(
  //                 ChartHelper.formatCurrency(value),
  //                 style: const TextStyle(fontSize: 10),
  //               );
  //             },
  //           ),
  //         ),
  //       ),

  //       borderData: FlBorderData(show: false),
  //       gridData: FlGridData(show: true),

  //       barGroups: List.generate(values.length, (index) {
  //         return BarChartGroupData(
  //           x: index,
  //           barRods: [
  //             BarChartRodData(
  //               toY: values[index] < 0 ? 0 : values[index],
  //               color: Colors.blue,
  //               width: 16,
  //               borderRadius: BorderRadius.circular(4),
  //             ),
  //           ],
  //         );
  //       }),
  //     ),
  //   );
  // }