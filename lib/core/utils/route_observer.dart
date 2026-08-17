import 'package:flutter/material.dart';

class RouteTrackingObserver extends NavigatorObserver {
  final ValueNotifier<String?> currentRoute = ValueNotifier(null);

  @override
  void didPush(Route route, Route? previousRoute) {
    currentRoute.value = route.settings.name;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRoute.value = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    currentRoute.value = newRoute?.settings.name;
  }
}
