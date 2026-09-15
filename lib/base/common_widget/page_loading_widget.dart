import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:learn_english_app/base/base.dart';

class PageLoadingWidget extends StatelessWidget {
  const PageLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
          child: SpinKitPulse(
            color: context.colorScheme.primary,
          )),
    );
  }
}
