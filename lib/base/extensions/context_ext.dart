import 'package:learn_english_app/base/utils/currency_symbols.dart';
import 'package:learn_english_app/l10n/share_localizations.dart';
import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/num_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/resources/app_resources.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
// TODO: Add localization when implemented
// import 'package:learn_english_app/generated/app_localizations.dart';

extension ContextExtension on BuildContext {
  Size get sizeScreen => MediaQuery.sizeOf(this);

  double get pixelRatio => MediaQuery.devicePixelRatioOf(this);

  ThemeData get currentThemes => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  String get currentLanguage => Localizations.localeOf(this).languageCode;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get ifTopNavigatorStack => ModalRoute.of(this)?.isCurrent ?? false;

  Color get colorText => colorScheme.brightness == Brightness.light ? colorScheme.secondary : colorScheme.secondary;

  String get currentScreen2 => GoRouterState.of(this).path ?? "";

  String get currentScreen => GoRouterState.of(this).uri.toString();

  String get sarCurrency => 'SAR'.toSarSymbol(currentLanguage);

  double getScaleFactor() {
    final width = sizeScreen.width;
    if (width > 600) {
      return width / 600;
    }
    if (width > 380) {
      return width / 380;
    }
    return 1;
  }

  void popUntilPath( String routePath) {
    while (
    GoRouter.of(this).routerDelegate.currentConfiguration.matches.last.matchedLocation !=
        routePath) {
      if (!canPop()) {
        return;
      }
      pop();
    }
  }

  void customAlertDialog(
      {required String title,
      required String contentMsg,
      Color? background,
      Color? titleColor = Colors.black87,
      Color? contentColor = Colors.black87,
      FontWeight? contentFontWeight,
      AlignmentGeometry titleAlign = AlignmentDirectional.topStart,
      double radius = 10,
      double minHeight = 150,
      double maxHeight = 180,
      bool dismissible = false,
      String? negativeLabel,
      Color? negativeLabelColor,
      required String positiveLabel,
      Color? positiveLabelColor,
      Color? positiveBackgroundColor,
      void Function()? onPositiveAction}) async {
    await showGeneralDialog(
        context: this,
        useRootNavigator: true,
        barrierDismissible: dismissible,
        barrierLabel: MaterialLocalizations.of(this).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
          return Center(
            child: Container(
              width: sizeScreen.width - 48,
              constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight),
              decoration: BoxDecoration(color: background ?? Colors.white, borderRadius: BorderRadius.circular(radius)),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                      alignment: titleAlign,
                      child: Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: titleColor),
                      )),
                  13.ph,
                  Text(
                    contentMsg,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: textTheme.titleSmall?.copyWith(color: contentColor,fontWeight: contentFontWeight),
                  ),
                  10.ph,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (negativeLabel != null)
                        TextButton(
                          onPressed: () {
                            Navigator.of(this, rootNavigator: true).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: background,
                            shape: const RoundedRectangleBorder(),
                          ),
                          child: Text(
                            negativeLabel,
                            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: negativeLabelColor),
                          ),
                        ),
                      16.pw,
                      TextButton(
                        onPressed: () {
                          Navigator.of(this, rootNavigator: true).pop(onPositiveAction != null ? 'action' : null);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: positiveBackgroundColor,
                          shadowColor: Colors.transparent,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: Text(
                          positiveLabel,
                          style: textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold, color: positiveLabelColor ?? colorScheme.primary),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }).then((value) => value != null ? onPositiveAction?.call() : null);
  }

  AppLocalizations get localization => AppLocalizations.of(this)!;

  void showSuccessfulSnackbar(String message,{double bottomMargin = 110}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.titleMedium?.copyWith(color: Colors.white,fontWeight: FontWeight.bold),
        ),
        duration: Duration(milliseconds: 1500),
        backgroundColor: AppColor.greenColor,
        behavior: SnackBarBehavior.floating,
        margin:   EdgeInsetsDirectional.only(start: 16, end: 16,bottom: bottomMargin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void showFailureSnackbar(String message,{double bottomMargin = 110}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          maxLines: 3,
          style: textTheme.titleMedium?.copyWith(color: Colors.white,fontWeight: FontWeight.bold),
        ),
        duration: Duration(milliseconds: 1500),
        backgroundColor: AppColor.redColor,
        behavior: SnackBarBehavior.floating,
        margin:   EdgeInsetsDirectional.only(start: 16, end: 16,bottom: bottomMargin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void showInfoSnackbar(String message,{double bottomMargin = 110}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.titleMedium?.copyWith(color: Colors.black,fontWeight: FontWeight.bold),
        ),
        duration: Duration(milliseconds: 1500),
        backgroundColor: AppColor.infoColor,
        behavior: SnackBarBehavior.floating,
        margin:   EdgeInsetsDirectional.only(start: 16, end: 16,bottom: bottomMargin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  void showTopError(String message) => showTopSnackBar(
    Overlay.of(this),
    CustomSnackBar.error(maxLines: 6, message: message),

    displayDuration: const Duration(milliseconds: 1800),
  );

  void showTopSuccess(String message) => showTopSnackBar(
    Overlay.of(this),
    CustomSnackBar.success(message: message),
    displayDuration: const Duration(milliseconds: 1800),
  );


}

extension FormAutoScroll on GlobalKey<FormState> {
  bool validateAndScroll() {
    final bool isValid = currentState?.validate() ?? false;

    if (!isValid) {
      Element? firstErrorElement;

      void findFirstError(Element element) {
        if (firstErrorElement != null) return;

        if (element.widget is FormField) {
          final state = (element as StatefulElement).state as FormFieldState;

          if (state.hasError) {
            firstErrorElement = element;
            return;
          }
        }

        element.visitChildren(findFirstError);
      }

      currentContext?.visitChildElements(findFirstError);

      if (firstErrorElement != null) {
        Scrollable.ensureVisible(
          firstErrorElement!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    }

    return isValid;
  }
}
