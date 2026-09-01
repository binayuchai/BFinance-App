import 'package:bfinance/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/currency_provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final summary = provider.summary;
    final colorScheme = Theme.of(context).colorScheme;

    final isNegative = summary.netBalance < 0;

    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 2.0,
      color: colorScheme
          .surfaceContainerHigh, // adapts to light/dark automatically
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Net Balance",
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    "${currencyProvider.currencyCode} ${summary.netBalance.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      // Balance is your most important number — high
                      // contrast normally, warning color if negative.
                      color: isNegative
                          ? colorScheme.error
                          : colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.wallet,
                    color: colorScheme.onPrimaryContainer,
                    size: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    icon: Icons.arrow_upward_rounded,
                    iconColor:
                        colorScheme.tertiary, // theme-driven "positive" color
                    label: "Income",
                    amount: summary.totalIncome,
                    currencyCode: currencyProvider.currencyCode,
                    colorScheme: colorScheme,
                  ),
                ),
                Container(
                  height: 36,
                  width: 1,
                  color: colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _SummaryTile(
                    icon: Icons.arrow_downward_rounded,
                    iconColor: colorScheme.error,
                    label: "Expenses",
                    amount: summary.totalExpenses,
                    currencyCode: currencyProvider.currencyCode,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final double amount;
  final String currencyCode;
  final ColorScheme colorScheme;

  const _SummaryTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  "$currencyCode ${amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
