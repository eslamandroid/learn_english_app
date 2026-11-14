import 'package:flutter/material.dart';

import '../../../../core/speech/sentence_assessment.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/widgets/play_my_voice_button.dart';

/// "YOU SAID · 75%" result box shown under the sentence after an STT attempt.
///
/// Warm amber for < 85% ("YOU SAID"); green for ≥ 85% ("GREAT") — matches
/// TASK_sentences_ui_redesign §3.1. Mismatched words are highlighted with
/// an amber background and a solid colour underline (Flutter has no wavy
/// underline style, so a solid line is used as the closest equivalent).
class RepeatResultBox extends StatelessWidget {
  final SentenceAssessment assessment;
  final VoidCallback onTryAgain;

  /// Absolute path to the user's recorded take for this attempt, if the
  /// parallel recorder produced one (TASK 12). Null hides the replay affordance.
  final String? recordingPath;

  const RepeatResultBox({
    super.key,
    required this.assessment,
    required this.onTryAgain,
    this.recordingPath,
  });

  bool get _isGreat => assessment.score >= 0.85;

  Color get _bg =>
      _isGreat ? BayanColors.successTint : BayanColors.warnTint;
  Color get _fg => _isGreat ? BayanColors.successFg : BayanColors.warnFg;
  Color get _border => _isGreat ? BayanColors.successStrong : BayanColors.warn;
  String get _label => _isGreat ? 'GREAT' : 'YOU SAID';

  @override
  Widget build(BuildContext context) {
    final pct = (assessment.score * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _bg,
        border: Border.all(color: _border.withValues(alpha: .55)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$_label · $pct%',
                  style: BayanTypography.labelMedium.copyWith(
                    color: _fg,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.06 * 11,
                  ),
                ),
              ),
              if (recordingPath != null) ...[
                PlayMyVoiceButton(recordingPath: recordingPath),
                const SizedBox(width: 4),
              ],
              GestureDetector(
                onTap: onTryAgain,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'Try again',
                  style: BayanTypography.labelMedium.copyWith(
                    color: _fg,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _AttemptLine(words: assessment.words, isGreat: _isGreat),
        ],
      ),
    );
  }
}

class _AttemptLine extends StatelessWidget {
  final List<WordResult> words;
  final bool isGreat;
  const _AttemptLine({required this.words, required this.isGreat});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: BayanTypography.bodyMedium.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: BayanColors.onSurface,
        ),
        children: [
          for (var i = 0; i < words.length; i++) ...[
            if (i > 0) const TextSpan(text: ' '),
            if (words[i].isCorrect)
              TextSpan(text: words[i].word)
            else
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: _MismatchedChip(text: words[i].word),
              ),
          ],
        ],
      ),
    );
  }
}

class _MismatchedChip extends StatelessWidget {
  final String text;
  const _MismatchedChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: BayanColors.warnHighlight,
        borderRadius: BorderRadius.circular(4),
        border: const Border(
          bottom: BorderSide(color: BayanColors.warnUnderline, width: 2),
        ),
      ),
      child: Text(
        text,
        style: BayanTypography.bodyMedium.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: BayanColors.onSurface,
        ),
      ),
    );
  }
}
