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
      height: 260,
      child: LineChart(
        LineChartData(
          minY: 0,
          minX: 0,
          maxX: (values.length - 1)
              .toDouble(), // Set maxX based on the number of data points
          // maxY: (values.isEmpty
          //     ? 100
          //     : (values.reduce((a, b) => a > b ? a : b) *
          //           1.1)), // Add 10% padding to maxY
          maxY: (values.isEmpty
              ? 100
              : (values.fold(0.0, (a, b) => a > b ? a : b) *
                    1.2)), // Add 20% padding to maxY for better visualization
          clipData: FlClipData(
            top: false,
            bottom: true,
            left: true,
            right: true,
          ), // Prevent area from extending below x-axis
          gridData: FlGridData(
            //controls the visual grid lines displayed on the chart
            // Show grid lines
            show: true,
            drawVerticalLine: true, // Show vertical grid lines
            drawHorizontalLine: true, // Show horizontal grid lines
            horizontalInterval: 200000, // Set horizontal grid line interval
            verticalInterval: null,
          ),
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
            //Configure for right titles (Y-axis)
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // Hide right Y-axis titles
              ),
            ),
            // Configure left titles (Y-axis)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: null,
                reservedSize: 60, // Reserve space to prevent overlap
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      ChartHelper.formatCurrency(
                        value,
                      ), // Format Y-axis values as currency
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                // reservedSize: 40, // Reserve space for month labels
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        labels[index],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    );
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
