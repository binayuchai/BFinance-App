import 'package:bfinance/features/analytics/helper/chart_theme.dart';
import 'package:bfinance/features/analytics/helper/format_currency.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String currencyCode;
  const MonthlyChart({
    super.key,
    required this.values,
    required this.labels,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chartTheme = ChartTheme.of(context);

    final maxValue = values.isEmpty
        ? 100.0
        : values.fold(0.0, (a, b) => a > b ? a : b);
    final maxY = maxValue == 0 ? 100.0 : maxValue * 1.2;
    // Derive a "nice" grid interval from the actual data range instead of a
    // hardcoded number, so grid lines always line up with axis labels.
    final gridInterval = maxY / 4;
    return SizedBox(
      height: 260,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),

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
            maxY: maxY,
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
              drawVerticalLine: false, // Don't show vertical grid lines
              // drawHorizontalLine: true, // Show horizontal grid lines
              horizontalInterval:
                  gridInterval, // Set horizontal grid line interval
              // verticalInterval: null,
              getDrawingHorizontalLine: (value) => FlLine(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                strokeWidth: 1,
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => chartTheme
                    .tooltipBackground, // Use theme color for tooltip background

                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      ChartHelper.formatCurrency(spot.y, currencyCode),
                      TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
              getTouchedSpotIndicator: (barData, spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(color: colorScheme.primary, strokeWidth: 2),
                    FlDotData(
                      getDotPainter: (spot, percent, bar, i) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: colorScheme.surface,
                          ),
                    ),
                  );
                }).toList();
              },
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
                color: colorScheme.primary,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: colorScheme.primary,
                      strokeWidth: 2,
                      strokeColor: colorScheme.surface,
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
                  interval: gridInterval,
                  reservedSize: 43, // Reserve space to prevent overlap
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        ChartHelper.formatCurrency(
                          value,
                          currencyCode,
                        ), // Format Y-axis values as currency
                        style: chartTheme.smallAxisLabelStyle,
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
                          style: chartTheme.smallAxisLabelStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    } else {
                      return const Text("");
                    }
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
