import 'package:flutter/material.dart';

import '../../core/utils/content_language.dart';

/// Hides [child] when the user has disabled bilingual content in Settings
/// (`AppContentLanguage.instance.showArabic == false`). Reactive — flipping
/// the toggle rebuilds every subscriber.
///
/// Use it around Arabic-only branches in feature widgets (titles, body
/// translations, example translations, etc.). `BilingualText` consults the
/// same flag internally, so widgets built on it don't need to wrap.
///
/// `[fallback]` is rendered when Arabic is hidden — defaults to
/// `SizedBox.shrink()` so the row simply collapses.
class ArabicVisibility extends StatelessWidget {
  final Widget child;
  final Widget fallback;

  const ArabicVisibility({
    super.key,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppContentLanguage.instance.showArabic,
      builder: (context, visible, _) => visible ? child : fallback,
    );
  }
}
