import 'package:flutter/material.dart';
 import 'package:go_router/go_router.dart';
import 'package:learn_english_app/base/common_widget/page_transition.dart';
 import 'package:learn_english_app/features/splash/splash_screen.dart';

class RouteDefinitions {
  static Page splashPage(GoRouterState state) {
    return PageTransition(
      key: state.pageKey,
      alignment: Alignment.center,
      duration: const Duration(milliseconds: 150),
      type: PageTransitionType.fade,
      child: const SplashScreen(),
    );
  }

}
