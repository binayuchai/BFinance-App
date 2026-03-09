import 'package:bfinance/features/analytics/helper/format_currency.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  const MonthlyChart({super.key, required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minY: 0,
          minX: 0,
          maxX: (values.length - 1)
              .toDouble(), // Set maxX based on the number of data points
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                values.length,
                (index) => FlSpot(index.toDouble(), values[index]),
              ),
              isCurved: true,
              barWidth: 3,
              preventCurveOverShooting: true,
              color: Colors.blue,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.blue,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ), // Show dots on data points

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.3),
                    Colors.blue.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            // Configure left titles (Y-axis)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: null,
                getTitlesWidget: (value, meta) {
                  return Text(
                    ChartHelper.formatCurrency(
                      value,
                    ), // Format Y-axis values as currency
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
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
      ),
    );
  }
}

// Old code for reference:

//  Widget buildLineChart(List<double> values, List<String> labels) {
//     return LineChart(
//       LineChartData(
//         lineBarsData: [
//           LineChartBarData(
//             spots: List.generate(
//               values.length,
//               (index) => FlSpot(index.toDouble(), values[index]),
//             ),
//             isCurved: true,
//             barWidth: 3,
//             preventCurveOverShooting: true,
//             color: Colors.blue,
//             dotData: FlDotData(show: true), // Show dots on data points
//           ),
//         ],
//         titlesData: FlTitlesData(
//           // Configure left titles (Y-axis)
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               interval: null,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   ChartHelper.formatCurrency(
//                     value,
//                   ), // Format Y-axis values as currency
//                   style: const TextStyle(fontSize: 10),
//                 );
//               },
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 int index = value.toInt();
//                 if (index < labels.length) {
//                   return Text(labels[index]);
//                 } else {
//                   return const Text("");
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
