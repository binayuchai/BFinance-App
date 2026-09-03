import 'package:bfinance/features/analytics/helper/chart_theme.dart';
import 'package:bfinance/features/analytics/helper/format_currency.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String currencyCode;
  const WeeklyChart({
    super.key,
    required this.values,
    required this.labels,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    final chartTheme = ChartTheme.of(context);
    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue <= 0 ? 100.0 : maxValue * 1.25;
    // Round the grid interval
    final rawInterval = maxY / 4;
    final gridInterval = rawInterval <= 0 ? 25.0 : rawInterval;

    return LayoutBuilder(
      builder: (context, constraints) {
        //Responsive bar width: widet when there are fewer bars, narrower
        // when there are many, so bars never overlap
        final availableWidth = constraints.maxWidth - 50;
        final barCount = values.isEmpty ? 1 : values.length;
        final rawBarWidth = (availableWidth / barCount) * 0.5;
        final barWidth = rawBarWidth.clamp(10.0, 28.0);
        return SizedBox(
          height: 270,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),

            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                groupsSpace: 12,

                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => chartTheme.tooltipBackground,
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = groupIndex < labels.length
                          ? labels[groupIndex]
                          : '';
                      return BarTooltipItem(
                        '$label\n',
                        chartTheme.tooltipTextStyle.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                        ),
                        children: [
                          TextSpan(
                            text: ChartHelper.formatCurrency(
                              rod.toY,
                              currencyCode,
                            ),
                            style: chartTheme.tooltipTextStyle,
                          ),
                        ],

                        // ChartHelper.formatCurrency(rod.toY, currencyCode),

                        // chartTheme.tooltipTextStyle,
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
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
                        }
                        return const Text("");
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: gridInterval,
                      getTitlesWidget: (value, meta) {
                        // Skip drawing a label crammed right at the very top edge
                        if (value == 0) {
                          return Text(
                            '0',
                            style: chartTheme.smallAxisLabelStyle,
                          );
                        }
                        return Text(
                          ChartHelper.formatCurrency(value, currencyCode),
                          style: chartTheme.smallAxisLabelStyle,
                        );

                        // return Text(
                        //   value >= 1000
                        //       ? '${(value / 1000).toStringAsFixed(1)}k'
                        //       : value.toStringAsFixed(0),
                        //   style: chartTheme.smallAxisLabelStyle,
                        // );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: gridInterval,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: chartTheme.gridLineColor, strokeWidth: 1),
                ),

                barGroups: List.generate(values.length, (index) {
                  final value = values[index] < 0 ? 0.0 : values[index];

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: chartTheme.dataColor,
                        width: barWidth,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: chartTheme.gridLineColor.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
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
  //                 ChartHelper.formatCurrency(value, currencyCode),
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