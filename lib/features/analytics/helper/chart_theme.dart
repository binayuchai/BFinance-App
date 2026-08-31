import 'package:flutter/material.dart';

/// Central place for chart styling so all charts (line, bar, donut)
/// stay visually consistent and theme-aware without repeating code.
class ChartTheme {
  final ColorScheme colorScheme;
  ChartTheme(this.colorScheme);

  factory ChartTheme.of(BuildContext context) =>
      ChartTheme(Theme.of(context).colorScheme);

  // Main data color (bars, lines)
  Color get dataColor => colorScheme.primary;

  // Faint grid lines that work in both light and dark mode
  Color get gridLineColor => colorScheme.outlineVariant.withValues(alpha: 0.4);

  // Axis label text style
  TextStyle get axisLabelStyle => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: colorScheme.onSurfaceVariant,
  );

  // Smaller axis style, used by WeeklyChart's more compact labels
  TextStyle get smallAxisLabelStyle =>
      TextStyle(color: colorScheme.outline, fontSize: 10);

  // Tooltip background/text
  Color get tooltipBackground => colorScheme.secondaryContainer;
  TextStyle get tooltipTextStyle => TextStyle(
    color: colorScheme.onSecondaryContainer,
    fontWeight: FontWeight.bold,
  );

  // Center/heading text on donut chart
  TextStyle get primaryValueStyle => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: colorScheme.onSurface,
  );

  TextStyle get secondaryLabelStyle =>
      TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant);
}
