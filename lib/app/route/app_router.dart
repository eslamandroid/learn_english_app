import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/app/route/route_constants.dart';
import 'package:learn_english_app/app/route/route_definitions.dart';
import 'package:learn_english_app/app/route/route_error_screen.dart';

final GlobalKey<NavigatorState> appRouter = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> mainRouter = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> authRouter = GlobalKey<NavigatorState>();
StatefulNavigationShell? mainShell;
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

final GoRouter router = GoRouter(
  initialLocation: RouteConstants.splash,
  navigatorKey: appRouter,
  observers: [routeObserver],
  debugLogDiagnostics: true,
  errorBuilder: (context, state) => const RouteErrorScreen(),
  routes: [
    GoRoute(
      path: RouteConstants.splash,
      name: 'splash',
      pageBuilder: (context, state) => RouteDefinitions.splashPage(state),
    ),
  ],
);


class RouterUtils {
  /// Go back to previous route
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // context.go(RouteConstants.home);
    }
  }

  /// Check if current route can go back
  static bool canGoBack(BuildContext context) {
    return context.canPop();
  }

  /// Get current route name
  static String? getCurrentRouteName(BuildContext context) {
    return GoRouterState.of(context).name;
  }

  /// Get current route path
  static String getCurrentRoutePath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }
}
