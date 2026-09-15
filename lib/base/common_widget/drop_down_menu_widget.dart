import 'package:flutter/material.dart';
import 'package:learn_english_app/base/base.dart';

class DropdownMenuWidget extends FormField<String> {
  DropdownMenuWidget({
    Key? key,
    String? initialValue,
    required String label,
    required String hint,
    required VoidCallback onTap,
    DropdownMenuController? controller,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
    TextStyle? contentStyle,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    double? height,
    double? fontSize,
    EdgeInsetsGeometry? padding,
    IconData? icon,
    double? iconSize,
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> field) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (controller?.value != field.value) {
                field.didChange(controller?.value);
              }
            });

            final value = controller?.value ?? '';
            final hasValue = value.isNotEmpty;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  label,
                  style: labelStyle??field.context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    onTap();
                   },
                  child: Container(
                    height: height ?? 48,
                    alignment: Alignment.center,
                    padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: field.hasError && controller?.value == null
                            ? field.context.colorScheme.error
                            : field.context.colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            hasValue ? value : hint,
                            style:
                            (hasValue?contentStyle:hintStyle) ??
                                field.context.textTheme.bodyLarge?.copyWith(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w500,
                                  color: hasValue ? null : Colors.black45,
                                ),
                          ),
                        ),
                        Icon(
                          icon ?? Icons.keyboard_arrow_down_rounded,
                          color: Colors.black38,
                          size: iconSize ?? 24,
                        ),
                      ],
                    ),
                  ),
                ),
                if (field.hasError && controller?.value == null) ...[
                   Text(
                    field.errorText!,
                    style: field.context.textTheme.bodySmall
                        ?.copyWith(color: field.context.colorScheme.error),
                  ).paddingTBSE(start: 10,top: 10),
                ]
              ],
            );
          },
        );
}

class DropdownMenuController extends ChangeNotifier {
  String? _value;

  String? get value => _value;

  set value(String? newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  void clear() {
    _value = null;
    notifyListeners();
  }
}
