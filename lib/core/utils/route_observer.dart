import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RouteTrackingObserver extends NavigatorObserver {
  final ValueNotifier<String?> currentRoute = ValueNotifier(null);

  @override
  void didPush(Route route, Route? previousRoute) {
    // currentRoute.value = route.settings.name;
    _updateRoute(route.settings.name);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // currentRoute.value = previousRoute?.settings.name;
    _updateRoute(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    // currentRoute.value = newRoute?.settings.name;
    _updateRoute(newRoute?.settings.name);
  }


  void _updateRoute(String? name){
    SchedulerBinding.instance.addPostFrameCallback((_){
      currentRoute.value = name;

    });
  }
}
