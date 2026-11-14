import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders one of the bundled `ph_*.svg` phrase illustrations. Unknown keys
/// (including null) fall back to `ph_other.svg` and are logged in debug —
/// per TASK_sentences_ui_redesign §1.3, this widget must never throw.
class SentenceTopicIllustration extends StatelessWidget {
  final String? iconKey;
  final double size;

  const SentenceTopicIllustration({
    super.key,
    required this.iconKey,
    this.size = 68,
  });

  static const Set<String> _known = {
    'ph_basic',
    'ph_car',
    'ph_communication',
    'ph_dating',
    'ph_education',
    'ph_fire',
    'ph_general',
    'ph_health',
    'ph_hotel',
    'ph_job',
    'ph_leisure_time',
    'ph_making_friends',
    'ph_other',
    'ph_plane',
    'ph_restaurant',
    'ph_services',
    'ph_shopping',
    'ph_time_weather',
    'ph_travel',
    'ph_work',
  };

  static const String _fallback = 'ph_other';

  static String assetFor(String? key) {
    if (key != null && _known.contains(key)) {
      return 'assets/icons/$key.svg';
    }
    if (kDebugMode) {
      debugPrint(
        '[SentenceTopicIllustration] unknown icon key: '
        '"$key" → falling back to $_fallback.svg',
      );
    }
    return 'assets/icons/$_fallback.svg';
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetFor(iconKey),
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
