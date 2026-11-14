import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// Raised dictionary search field — a white card with a soft shadow when
/// empty, gaining a thin primary border + primary search icon the moment it
/// holds any text (TASK_09 §1).
///
/// Behaviours worth calling out:
///   • Typing is debounced before firing [onChanged] (default 300ms) so we
///     don't hit the DB for every keystroke across 5,586 rows.
///   • Tapping the Clear button bypasses the debounce and fires `onChanged('')`
///     immediately so the full unfiltered list reloads with no delay. It also
///     keeps keyboard focus in the field so the user can start a fresh search
///     right away (TASK_09 §2).
///   • A controller listener drives a `setState` on every text edit — without
///     it, the suffix Clear button never appears because the field widget
///     itself does not rebuild its stateful parent on text change.
class DictionarySearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final Duration debounce;
  final String? initialValue;

  const DictionarySearchBar({
    super.key,
    required this.onChanged,
    this.debounce = const Duration(milliseconds: 300),
    this.initialValue,
  });

  @override
  State<DictionarySearchBar> createState() => _DictionarySearchBarState();
}

class _DictionarySearchBarState extends State<DictionarySearchBar> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue ?? '');
  final FocusNode _focusNode = FocusNode();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Drives suffix-icon visibility + border/icon colour transitions.
    _controller.addListener(_onControllerChanged);
    _focusNode.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _focusNode.removeListener(_onControllerChanged);
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _handleChange(String value) {
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(value));
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    // Keep the field focused so the keyboard stays up for the next query.
    _focusNode.requestFocus();
    // Bypass the debounce — Clear should feel instant.
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    final accentActive = hasText || _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: accentActive
            ? Border.all(
                color: BayanColors.primary.withValues(alpha: 0.25),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: BayanColors.onSurface.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 18,
            color: accentActive
                ? BayanColors.primary
                : BayanColors.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _handleChange,
              textInputAction: TextInputAction.search,
              style: BayanTypography.bodyMedium.copyWith(
                color: BayanColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search in English or Arabic',
                hintStyle: BayanTypography.bodyMedium.copyWith(
                  color: BayanColors.onSurfaceVariant,
                ),
                isDense: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          if (hasText) ...[
            const SizedBox(width: 8),
            _ClearButton(onTap: _clear),
          ],
        ],
      ),
    );
  }
}

/// Small 24×24 circular Clear button rendered inside the search field once
/// the user types anything. Kept as its own widget so the test for its
/// presence/absence can target `_ClearButton` by type-match via a tooltip.
class _ClearButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ClearButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Clear search',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BayanColors.outlineVariant.withValues(alpha: 0.30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: BayanColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
