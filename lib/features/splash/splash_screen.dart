import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/app/route/route_constants.dart';
import 'package:learn_english_app/resources/app_resources.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 2), () {
      _checkAndNavigate();
    });
  }

  void _checkAndNavigate() async {
    if (!mounted) return;

  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.appBackground,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColor.appBackground,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Image.asset(AppImages.appLogoColored, height: 150)),
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}
