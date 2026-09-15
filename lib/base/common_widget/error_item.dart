import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_english_app/base/base.dart';
import 'package:learn_english_app/resources/app_resources.dart';

class ErrorItem extends StatelessWidget {
  final AppException exception;
  final void Function() tryAgain;

  const ErrorItem({super.key, required this.exception, required this.tryAgain});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (context.hasNetworkError(exception)) ...[
          Image.asset("assets/images/no_internet.png", height: 120.h),
          24.ph,
        ],
        16.ph,
        Text(
          context.exceptionMessage(exception),
          maxLines: 4,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        24.ph,
        TextButton(
          onPressed: tryAgain,
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            backgroundColor: AppColor.appPrimaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
            ),
          ),
          child: Text(
            context.localization.retryLabel,
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColor.appWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
