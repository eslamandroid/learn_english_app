import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';

enum HighlightStyle {
  /// Inline bold + colored phrase (e.g. the literal `'s'`).
  boldAccent,

  /// Pill chip with tinted background (e.g. pronoun tokens).
  chip,
}

/// Renders [text] as a single rich-text paragraph with the listed
/// [highlights] visually called out. Each highlight is matched case-insensitively
/// and tolerantly across word boundaries.
class HighlightedText extends StatelessWidget {
  final String text;
  final List<String> highlights;
  final TextStyle baseStyle;
  final HighlightStyle style;

  const HighlightedText({
    super.key,
    required this.text,
    required this.highlights,
    required this.baseStyle,
    this.style = HighlightStyle.boldAccent,
  });

  @override
  Widget build(BuildContext context) {
    final spans = _buildSpans(text, highlights, baseStyle, style);
    return Text.rich(
      TextSpan(children: spans, style: baseStyle),
      style: baseStyle,
    );
  }
}

List<InlineSpan> _buildSpans(
  String text,
  List<String> highlights,
  TextStyle base,
  HighlightStyle style,
) {
  if (highlights.isEmpty || text.isEmpty) {
    return [TextSpan(text: text, style: base)];
  }

  // Build a single regex of escaped highlights, longest first so substrings
  // don't shadow longer matches (e.g. "he" before "he, she").
  final ordered = [...highlights]..sort((a, b) => b.length.compareTo(a.length));
  final pattern = ordered.map(RegExp.escape).join('|');
  final regex = RegExp(pattern, caseSensitive: false);

  final spans = <InlineSpan>[];
  var cursor = 0;
  for (final m in regex.allMatches(text)) {
    if (m.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, m.start), style: base));
    }
    spans.add(_styledSpan(m.group(0)!, base, style));
    cursor = m.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor), style: base));
  }
  return spans;
}

InlineSpan _styledSpan(String match, TextStyle base, HighlightStyle style) {
  switch (style) {
    case HighlightStyle.boldAccent:
      return TextSpan(
        text: match,
        style: base.copyWith(
          color: BayanColors.primary,
          fontWeight: FontWeight.w800,
        ),
      );
    case HighlightStyle.chip:
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: BayanColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          child: Text(
            match,
            style: base.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: BayanColors.onSurface,
            ),
          ),
        ),
      );
  }
}
