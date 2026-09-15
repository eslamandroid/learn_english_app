import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:learn_english_app/base/extensions/extensions.dart';

Future showLoadingDialog({
  required BuildContext context,
  Color? color = Colors.black,
  double? size = 30,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.only(left: 120.0, right: 120.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        content: Builder(
          builder: (context) {
            return SizedBox(
              height: 50,
              width: 50,
              child: Center(
                heightFactor: 1,
                widthFactor: 1,
                child: SizedBox(
                  height: size,
                  width: size,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 5,
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Future showFullLoadingDialog({required BuildContext context}) {
  return showDialog(
    context: context,
    useSafeArea: false,
    barrierColor: Colors.transparent,
    useRootNavigator: true,
    builder: (context) {
      return Stack(
        children: [
          const Opacity(
            opacity: 0.72,
            child: ModalBarrier(dismissible: false, color: Colors.white),
          ),
          Center(child: SpinKitPulse(color: context.colorScheme.primary)),
          //
        ],
      );
    },
  );
}

class DialogManager {
  static bool _isDialogShowing = false;

  static Future<void> showFullLoadingDialog({
    required BuildContext context,
  }) async {
    if (_isDialogShowing) return;

    _isDialogShowing = true;

    await showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) {
        return Stack(
          children: [
            const Opacity(
              opacity: 0.72,
              child: ModalBarrier(dismissible: false, color: Colors.white),
            ),
            Center(
              child: SpinKitPulse(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        );
      },
    );

    _isDialogShowing = false;
  }

  static void dismissDialog(BuildContext context) {
    if (_isDialogShowing) {
      _isDialogShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static Future<void> showInfoDialog({
    required BuildContext context,
    required String content,
    String? title,
    String? buttonText,
    VoidCallback? onPressed,
    bool dismissible = true,
  }) async {
    if (_isDialogShowing) return;

    _isDialogShowing = true;

    await showDialog(
      context: context,
      barrierDismissible: dismissible,
      useRootNavigator: true,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => dismissible,
          child: AlertDialog(
            title:
                title != null
                    ? Text(
                      title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
            content: Text(content, style: context.textTheme.bodyMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigator.of(context, rootNavigator: true).pop();
                  onPressed?.call();
                },
                child: Text(
                  buttonText ?? 'OK',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    _isDialogShowing = false;
  }

  static bool get isDialogShowing => _isDialogShowing;
}
