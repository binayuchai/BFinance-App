import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/connectivity_provider.dart';

class OfflineIndicator extends StatelessWidget {
  final bool isOnline;
  const OfflineIndicator({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, //covers the FULL banner area
      onTap: isOnline
          ? null // don't allow tapping when already online / banner hidden
          : () => context.read<ConnectivityProvider>().recheckConnection(),
      child: ClipRect(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isOnline ? 0 : 32,
          width: double
              .infinity, // 👈 GestureDetector now inherits this full width
          color: Theme.of(context).colorScheme.error,
          child: OverflowBox(
            maxHeight: 32,
            alignment: Alignment.center,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isOnline ? 0 : 1,
              child: Consumer<ConnectivityProvider>(
                builder: (context, connectivity, _) {
                  final onError = Theme.of(context).colorScheme.onError;

                  if (connectivity.isChecking) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(onError),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Checking connection...',
                          style: TextStyle(
                            color: onError,
                            fontSize: 13,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 14, color: onError),
                      const SizedBox(width: 6),
                      Text(
                        'No internet connection · Tap to retry',
                        style: TextStyle(
                          color: onError,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
