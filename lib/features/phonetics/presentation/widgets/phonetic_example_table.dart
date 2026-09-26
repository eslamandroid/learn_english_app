import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../di/di.dart';
import '../../domain/entities/phonetic_example.dart';
import '../../domain/entities/pronunciation_outcome.dart';
import '../bloc/pronunciation/pronunciation_bloc.dart';
import '../bloc/pronunciation/pronunciation_event.dart';
import '../bloc/pronunciation/pronunciation_state.dart';
import 'bilingual_text.dart';

class PhoneticExampleTable extends StatelessWidget {
  final List<PhoneticExample> examples;
  final int? playingExampleId;
  final ValueChanged<PhoneticExample> onPlay;

  const PhoneticExampleTable({
    super.key,
    required this.examples,
    required this.playingExampleId,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    if (examples.isEmpty) return const SizedBox.shrink();
    return BlocProvider(
      create: (_) => getIt<PronunciationBloc>(),
      child: Column(
        children: [
          for (var i = 0; i < examples.length; i++) ...[
            _ExampleRow(
              example: examples[i],
              isPlaying: playingExampleId == examples[i].id,
              onPlay: () => onPlay(examples[i]),
            ),
            if (i < examples.length - 1)
              const SizedBox(height: AppConstants.spacingSm),
          ],
        ],
      ),
    );
  }
}

/// One row's `BlocSelector` scope — only this row rebuilds when its own
/// listening/result state changes, not the whole table.
class _ExampleRow extends StatelessWidget {
  final PhoneticExample example;
  final bool isPlaying;
  final VoidCallback onPlay;

  const _ExampleRow({
    required this.example,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PronunciationBloc, PronunciationState, _RowData>(
      selector: (state) => _RowData(
        isListening: state.activeExampleId == example.id,
        armed: state.activeExampleId == example.id && state.armed,
        partial: state.activeExampleId == example.id ? state.partialText : null,
        attempt: state.attempts[example.id],
      ),
      builder: (context, row) {
        return _ExampleCard(
          example: example,
          isPlaying: isPlaying,
          isListening: row.isListening,
          armed: row.armed,
          heard: row.isListening ? row.partial : row.attempt?.heard,
          outcome: row.attempt?.outcome,
          onPlay: onPlay,
          onMic: () {
            final bloc = context.read<PronunciationBloc>();
            if (row.isListening) {
              bloc.add(const StopPronunciationCheck());
            } else {
              bloc.add(StartPronunciationCheck(
                exampleId: example.id,
                targetWord: example.word,
              ));
            }
          },
        );
      },
    );
  }
}

class _RowData {
  final bool isListening;
  final bool armed;
  final String? partial;
  final PronunciationAttempt? attempt;

  const _RowData({
    required this.isListening,
    this.armed = false,
    this.partial,
    this.attempt,
  });
}

class _ExampleCard extends StatelessWidget {
  final PhoneticExample example;
  final bool isPlaying;
  final bool isListening;
  final bool armed;
  final String? heard;
  final PronunciationOutcome? outcome;
  final VoidCallback onPlay;
  final VoidCallback onMic;

  const _ExampleCard({
    required this.example,
    required this.isPlaying,
    required this.isListening,
    required this.armed,
    required this.heard,
    required this.outcome,
    required this.onPlay,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingSm + 2),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: BayanColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RoundButton(
                filled: isPlaying,
                icon: isPlaying
                    ? Icons.volume_up_rounded
                    : Icons.play_arrow_rounded,
                color: BayanColors.primary,
                onTap: onPlay,
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BilingualText(
                      en: example.word,
                      ar: example.wordAr,
                      primary: BayanTypography.titleLarge.copyWith(
                        color: BayanColors.onSurface,
                      ),
                      secondary: BayanTypography.bodySmall.copyWith(
                        color: BayanColors.onSurfaceVariant,
                      ),
                    ),
                    if ((example.phonetic ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          example.phonetic!,
                          style: BayanTypography.bodySmall.copyWith(
                            color: BayanColors.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              _RoundButton(
                filled: isListening,
                icon: Icons.mic_rounded,
                color: isListening ? BayanColors.error : BayanColors.primary,
                onTap: onMic,
              ),
            ],
          ),
          if (isListening || outcome != null) ...[
            const SizedBox(height: AppConstants.spacingSm),
            _Feedback(
              isListening: isListening,
              armed: armed,
              heard: heard,
              outcome: outcome,
            ),
          ],
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final bool filled;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoundButton({
    required this.filled,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color : color.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color: filled ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  final bool isListening;
  final bool armed;
  final String? heard;
  final PronunciationOutcome? outcome;

  const _Feedback({
    required this.isListening,
    required this.armed,
    required this.heard,
    required this.outcome,
  });

  @override
  Widget build(BuildContext context) {
    if (isListening) {
      if (!armed) {
        // Mic tapped, but the engine hasn't confirmed it's actually
        // capturing yet — telling the user to speak now would be a lie;
        // this is exactly the "said it too fast and it didn't catch"
        // window if they don't wait for it.
        return _strip(
          bg: BayanColors.primary.withValues(alpha: 0.08),
          fg: BayanColors.primary,
          icon: Icons.hourglass_top_rounded,
          text: 'Getting ready…',
        );
      }
      final partial = (heard ?? '').trim();
      return _strip(
        bg: BayanColors.primary.withValues(alpha: 0.08),
        fg: BayanColors.primary,
        icon: Icons.graphic_eq_rounded,
        text: partial.isEmpty ? 'Speak now' : '“$partial”',
      );
    }

    return switch (outcome) {
      PronunciationOutcome.correct => _strip(
          bg: BayanColors.success.withValues(alpha: 0.12),
          fg: BayanColors.success,
          icon: Icons.check_circle_rounded,
          text: 'Great! That sounds right.',
        ),
      PronunciationOutcome.incorrect => _strip(
          bg: BayanColors.error.withValues(alpha: 0.10),
          fg: BayanColors.error,
          icon: Icons.refresh_rounded,
          text: (heard ?? '').trim().isEmpty
              ? 'Not quite — try again.'
              : 'Heard “${heard!.trim()}” — try again.',
        ),
      PronunciationOutcome.noSpeech => _strip(
          bg: BayanColors.warning.withValues(alpha: 0.12),
          fg: BayanColors.warning,
          icon: Icons.hearing_disabled_rounded,
          text: "Didn't catch that — try again.",
        ),
      PronunciationOutcome.denied => _strip(
          bg: BayanColors.error.withValues(alpha: 0.10),
          fg: BayanColors.error,
          icon: Icons.mic_off_rounded,
          text: 'Microphone permission is needed to practice.',
        ),
      PronunciationOutcome.unavailable => _strip(
          bg: BayanColors.error.withValues(alpha: 0.10),
          fg: BayanColors.error,
          icon: Icons.error_outline_rounded,
          text: 'Speech recognition is unavailable on this device.',
        ),
      null => const SizedBox.shrink(),
    };
  }

  Widget _strip({
    required Color bg,
    required Color fg,
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm + 2,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              text,
              style: BayanTypography.labelMedium.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
