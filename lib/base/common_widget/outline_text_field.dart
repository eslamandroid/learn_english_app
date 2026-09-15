import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/extensions.dart';

typedef FormFieldValidation<T> = String Function(T? newValue);

typedef FormFieldWidgetValidation<T> = Widget Function(T? newValue);

class OutlineTextFormField extends StatefulWidget {
  final Widget? labelTextWidget;
  final String? labelText;
  final TextDirection? labelDirection;
  final AlignmentGeometry labelAlignmentDirectional;
  final String? initValue;
  final double? labelTextSize;
  final double? textFieldSize;
  final FloatingLabelBehavior? floatingLabel;
  final String? hintText;
  final TextDirection? textDirection;
  final String? errorText;
  final TextStyle? hintStyle;
  final BoxConstraints? constraints;
  final bool labelExclude;
  final EdgeInsets labelContentPadding;
  final EdgeInsets? contentPadding;
  final Color? backgroundColor;
  final Color? focusBackgroundColor;
  final Color? focusColorBorder;
  final Color? outlineColorBorder;
  final Color? outlineEnableColorBorder;
  final Color labelColorFloating;
  final Color labelColor;
  final Color? tintEyePassword;
  final TextEditingController textEditingController;
  final FocusNode myFocusNode;
  final bool autofocus;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool enabled;
  final bool password;
  final bool requireField;
  final Widget? label;
  final Widget? suffix;
  final Widget? suffixStack;
  final AlignmentGeometry? alignmentStack;
  final Widget? prefixIcon;
  final bool validated;
  final bool enableCounter;
  final bool isDense;
  final bool readOnly;
  final void Function()? onTap;
  final int? maxLines;
  final int? minLines;
  final int? maxChar;
  final FormFieldValidation<String>? validation;
  final bool checkOfErrorOnFocusChange;
  final bool errorLine;
  final bool suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final ValueChanged<PointerDownEvent>? outerTouch;
  final FormFieldSetter<String>? onSaved;
  final TextStyle? counterStyle;
  final TextStyle? labelStyle;
  final TextStyle? contentStyle;
  final TextStyle? errorStyle;
  final TextStyle? floatingLabelStyle;
  final String? counterText;
  final double radius;
  final double? focusRadius;
  final double? borderWidthInActive;
  final FormFieldWidgetValidation<String>? passwordValidator;

  const OutlineTextFormField(
      {super.key,
      this.labelTextWidget,
      this.initValue,
      this.labelText,
      this.labelAlignmentDirectional = AlignmentDirectional.centerStart,
      this.labelDirection,
      this.requireField = false,
      this.labelTextSize,
      this.textFieldSize,
      this.borderWidthInActive,
      this.floatingLabel,
      this.hintText,
      this.errorText,
      this.tintEyePassword,
      this.hintStyle,
      this.label,
      this.textDirection,
      this.labelExclude = true,
      this.radius = 0.0,
      this.focusRadius,
      this.contentPadding,
      this.labelContentPadding = const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
      this.focusBackgroundColor,
      this.backgroundColor,
      this.focusColorBorder,
      this.outlineColorBorder,
      this.outlineEnableColorBorder,
      this.prefixIcon,
      this.readOnly = false,
      this.labelColorFloating = Colors.black54,
      this.labelColor = Colors.black,
      required this.textEditingController,
      required this.myFocusNode,
      this.autofocus = false,
      this.isDense = true,
      this.maxLines = 1,
      this.minLines = 1,
      this.maxChar,
      this.suffix,
      this.suffixStack,
      this.alignmentStack,
      this.onTap,
      this.constraints,
      required this.keyboardType,
      required this.textInputAction,
      this.enabled = true,
      this.password = false,
      this.validated = false,
      this.validation,
      this.passwordValidator,
      this.checkOfErrorOnFocusChange = false,
      this.errorLine = false,
      this.suffixIcon = false,
      this.enableCounter = true,

      this.inputFormatters,
      this.onFieldSubmitted,
      this.onChanged,
      this.counterText,
      this.counterStyle,
      this.labelStyle,
      this.contentStyle,
      this.errorStyle,
      this.floatingLabelStyle,
      this.onSaved,
      this.outerTouch});

  @override
  State<StatefulWidget> createState() => _OutlineTextFormField();
}

class _OutlineTextFormField extends State<OutlineTextFormField> {
  bool isError = false;
  String errorString = "";
  bool toggleEyes = true;
  int totalCounterText = 0;
  int counterTotalLength = 0;
  Widget? passwordWidget;
  String? errorText;
  TextDirection textDirection = TextDirection.rtl;
  TextDirection hintDirection = TextDirection.rtl;
  bool focused = false;

  getLabelTextStyle(color) =>
      widget.labelStyle ??
      context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      hintDirection = (context.currentLanguage == "ar") ? TextDirection.rtl : TextDirection.ltr;
    });

    if (widget.textEditingController.text.isNotEmpty) {
      textDirection = widget.textEditingController.text.toTextDirection;
    } else {
      textDirection = widget.textDirection ?? TextDirection.rtl;
    }

    if (widget.textDirection == null) {
      widget.textEditingController.addListener(() {
        final value = widget.textEditingController.text.toTextDirection;

        if (widget.textEditingController.text.isEmpty) {
          if (value != textDirection) {
            setState(() {
              textDirection =
                  (context.currentLanguage == "ar") ? TextDirection.rtl : TextDirection.ltr;
            });
          }
        } else {
          if (value != textDirection) {
            setState(() {
              textDirection = value;
            });
          }
        }
      });
    }

    if (widget.inputFormatters != null &&
        widget.inputFormatters?.firstOrNull is LengthLimitingTextInputFormatter) {
      counterTotalLength =
          ((widget.inputFormatters?[0] as LengthLimitingTextInputFormatter).maxLength ?? 0);
      totalCounterText = counterTotalLength;
    }

    passwordWidget = widget.passwordValidator != null ? widget.passwordValidator!("") : null;
  }

  @override
  void didUpdateWidget(covariant OutlineTextFormField oldWidget) {
    errorText = widget.errorText;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildLabelExcludeIfVisible(),
        FocusScope(
          child: Focus(
            onFocusChange: (focus) {
              focused = focus;
              if (widget.textDirection == null) {
                if (widget.textEditingController.text.isEmpty) {
                  setState(() {
                    textDirection =
                        (context.currentLanguage == "ar") ? TextDirection.rtl : TextDirection.ltr;
                  });
                }
              }
              if (errorText != null) {
                setState(() {
                  errorText = null;
                });
              }
              if (widget.validation?.call(widget.textEditingController.text) != null) {
                if (widget.checkOfErrorOnFocusChange &&
                    widget.validation!.call(widget.textEditingController.text).isNotEmpty) {
                  setState(() {
                    isError = true;
                    errorString = widget.validation!.call(widget.textEditingController.text);
                  });
                } else {
                  setState(() {
                    isError = false;
                    errorString = widget.validation!.call(widget.textEditingController.text);
                  });
                }
              }
            },
            child: Stack(
              alignment: widget.alignmentStack ?? AlignmentDirectional.topStart,
              children: [
                TextFormField(
                  initialValue: widget.initValue,
                  focusNode: widget.myFocusNode,
                  textDirection: textDirection,
                  controller: widget.textEditingController,
                  style: widget.contentStyle ?? context.textTheme.titleMedium,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  onChanged: (value) {
                    widget.onChanged?.call(value);

                    if (widget.counterText != null) {
                      setState(() {
                        totalCounterText = counterTotalLength - value.length;
                      });
                    }

                    if (widget.passwordValidator != null) {
                      setState(() {
                        passwordWidget = widget.passwordValidator!.call(value);
                      });
                    }
                  },
                  autocorrect: false,
                  autofocus: widget.autofocus,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  maxLength: widget.maxChar,
                  onTapOutside: widget.outerTouch ??
                      (_) {
                        widget.myFocusNode.unfocus();
                      },
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  obscureText: widget.password && toggleEyes,
                  validator: (string) {
                    if (widget.validation != null) {
                      if (widget.validation!.call(string).isNotEmpty) {
                        setState(() {
                          isError = true;
                          errorString = widget.validation!.call(string);
                        });

                        return errorString.isNotEmpty ? errorString : null;
                      } else {
                        setState(() {
                          isError = false;
                          errorString = widget.validation!.call(string);
                        });
                      }
                    }
                    return null;
                  },
                  onSaved: widget.onSaved,
                  onEditingComplete: () {},
                  cursorColor: context.colorScheme.primary,
                  decoration: InputDecoration(
                    filled: true,
                    suffixIcon: widget.password
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                toggleEyes = !toggleEyes;
                              });
                            },
                            child: Icon(
                              toggleEyes ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                              color: widget.tintEyePassword ?? Colors.black54,
                              size: 24,
                            ),
                          )
                        : widget.suffix,
                    prefixIcon: widget.prefixIcon,
                    alignLabelWithHint: true,

                    counterStyle:
                       widget.counterStyle?? context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    contentPadding:
                        widget.contentPadding ?? const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    fillColor: focused
                        ? widget.focusBackgroundColor ??
                            widget.backgroundColor ??
                            context.colorScheme.surface
                        : widget.backgroundColor ?? context.colorScheme.surface,
                    isDense: widget.isDense,
                    hintStyle: widget.hintStyle,
                    hintText: "${widget.hintText ?? ""}${widget.requireField ? "*" : ""}",
                    hintTextDirection: hintDirection,
                    errorText: errorText ?? (isError ? errorString : null),
                    error: null,
                    counterText:
                       widget.enableCounter? counterTotalLength > 0 ? "$totalCounterText/$counterTotalLength" : null:"",
                    constraints: widget.constraints,
                    enabled: widget.enabled,

                    helperText: null,
                    label: focused || widget.textEditingController.text.isNotEmpty
                        ? widget.label
                        : null,
                    errorMaxLines: 1,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(widget.radius),
                        borderSide: BorderSide(
                            color: widget.outlineColorBorder ?? context.colorScheme.outline,
                            width: 1)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(widget.radius),
                        borderSide: BorderSide(
                            color: context.colorScheme.error,
                            width: widget.borderWidthInActive ?? .5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(widget.focusRadius ?? widget.radius),
                        borderSide: BorderSide(
                            color: widget.focusColorBorder ?? context.colorScheme.primary,
                            width: widget.borderWidthInActive ?? .5)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(widget.radius),
                        borderSide: BorderSide(color: context.colorScheme.outline)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            widget.textEditingController.text.isNotEmpty
                                ? widget.focusRadius ?? widget.radius
                                : widget.radius),
                        borderSide: BorderSide(
                            color: widget.textEditingController.text.isNotEmpty
                                ? widget.outlineEnableColorBorder ??
                                    widget.outlineColorBorder ??
                                    context.colorScheme.outline
                                : widget.outlineColorBorder ?? context.colorScheme.outline,
                            width: 1)),
                  ),
                ),
                if (widget.suffixStack != null) widget.suffixStack!
              ],
            ),
          ),
        ),
        _buildPasswordValidator(),
      ],
    );
  }

  Widget _buildLabelExcludeIfVisible() {
    return widget.labelExclude
        ? Padding(
            padding: widget.labelContentPadding,
            child: Align(
              alignment: widget.labelAlignmentDirectional,
              child: Directionality(
                textDirection: widget.labelDirection ?? textDirection,
                child: widget.labelTextWidget ??
                    Text(
                      "${widget.labelText ?? ""}${widget.requireField ? "*" : ""}",
                      style: getLabelTextStyle(widget.myFocusNode.hasFocus
                          ? widget.labelColorFloating
                          : widget.labelColor),
                    ),
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _buildPasswordValidator() {
    return Visibility(
        visible: passwordWidget != null,
        child: passwordWidget != null ? passwordWidget! : const SizedBox());
  }
}
