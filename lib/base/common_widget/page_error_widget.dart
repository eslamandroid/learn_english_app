import 'package:flutter/material.dart';
import 'package:learn_english_app/base/errors/base/app_exception.dart' as appException;
import 'package:learn_english_app/base/errors/base/app_exception.dart';
import 'package:learn_english_app/base/errors/mapper/exception_message_mapper.dart';
import 'package:learn_english_app/base/extensions/extensions.dart';

class PageErrorWidget extends StatelessWidget {
  final AppException exception;
  final void Function() tryAgain;

  const PageErrorWidget({super.key, required this.exception, required this.tryAgain});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (context.hasNetworkError(exception)) ...[
              Image.asset("assets/images/no_internet.png", height: 120),
              24.ph,
            ],

            Text(
              "Something went wrong",
              maxLines: 4,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            24.ph,
            TextButton(
              onPressed: tryAgain,
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent,
                backgroundColor: context.colorScheme.primaryContainer,
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(
                context.localization.retryLabel,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ).paddingTBLE(left: 16.0, right: 16.0),
      ),
    );
  }
}

class PageErrorWidgetEx extends StatelessWidget {
  final appException.AppException exception;
  final void Function() tryAgain;

  const PageErrorWidgetEx({super.key, required this.exception, required this.tryAgain});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (context.hasNetworkError(exception)) ...[
              Image.asset("assets/images/no_internet.png", height: 120),
              24.ph,
            ],

            Text(
              context.exceptionMessage(exception),
              maxLines: 4,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            24.ph,
            TextButton(
              onPressed: tryAgain,
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent,
                backgroundColor: context.colorScheme.primaryContainer,
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(
                context.localization.retryLabel,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ).paddingTBLE(left: 16.0, right: 16.0),
      ),
    );
  }
}

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
        Text(
          "Something went wrong",
          maxLines: 4,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        24.ph,
        TextButton(
          onPressed: tryAgain,
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            backgroundColor: context.colorScheme.primaryContainer,
            shape: const RoundedRectangleBorder(),
          ),
          child: Text(
            context.localization.retryLabel,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class ErrorItemEx extends StatelessWidget {
  final appException.AppException exception;
  final void Function() tryAgain;

  const ErrorItemEx({super.key, required this.exception, required this.tryAgain});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          context.exceptionMessage(exception),
          maxLines: 4,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        24.ph,
        TextButton(
          onPressed: tryAgain,
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            backgroundColor: context.colorScheme.primaryContainer,
            shape: const RoundedRectangleBorder(),
          ),
          child: Text(
            context.localization.retryLabel,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
