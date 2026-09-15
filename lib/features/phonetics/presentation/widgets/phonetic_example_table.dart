import 'package:flutter/material.dart';

import '../../../../core/audio/pronunciation_checker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../domain/entities/phonetic_example.dart';
import 'bilingual_text.dart';

class PhoneticExampleTable extends StatefulWidget {
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
  State<PhoneticExampleTable> createState() => _PhoneticExampleTableState();
}

class _PhoneticExampleTableState extends State<PhoneticExampleTable> {
  int? _listeningId;
  final Map<int, String> _heard = {};
  final Map<int, PronunciationOutcome> _result = {};

  @override
  void dispose() {
    if (_listeningId != null) PronunciationChecker.instance.stop();
    super.dispose();
  }

  Future<void> _onMic(PhoneticExample ex) async {
    if (_listeningId == ex.id) {
      await PronunciationChecker.instance.stop();
      return; // onDone finalizes
    }
    if (_listeningId != null) {
      await PronunciationChecker.instance.stop();
    }

    setState(() {
      _listeningId = ex.id;
      _heard[ex.id] = '';
      _result.remove(ex.id);
    });

    final started = await PronunciationChecker.instance.start(
      onPartial: (text) {
        if (!mounted || _listeningId != ex.id) return;
        setState(() => _heard[ex.id] = text);
      },
      onDone: () => _finalize(ex),
    );

    if (!started && mounted) {
      setState(() {
        _listeningId = null;
        _result[ex.id] = PronunciationOutcome.denied;
      });
    }
  }

  void _finalize(PhoneticExample ex) {
    if (!mounted || _listeningId != ex.id) return;
    final heard = (_heard[ex.id] ?? '').trim();
    setState(() {
      _listeningId = null;
      if (heard.isEmpty) {
        _result[ex.id] = PronunciationOutcome.noSpeech;
      } else {
        _result[ex.id] = PronunciationChecker.matches(heard, ex.word)
            ? PronunciationOutcome.correct
            : PronunciationOutcome.incorrect;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.examples.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (var i = 0; i < widget.examples.length; i++) ...[
          _ExampleCard(
            example: widget.examples[i],
            isPlaying: widget.playingExampleId == widget.examples[i].id,
            isListening: _listeningId == widget.examples[i].id,
            heard: _heard[widget.examples[i].id],
            outcome: _result[widget.examples[i].id],
            onPlay: () => widget.onPlay(widget.examples[i]),
            onMic: () => _onMic(widget.examples[i]),
          ),
          if (i < widget.examples.length - 1)
            const SizedBox(height: AppConstants.spacingSm),
        ],
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final PhoneticExample example;
  final bool isPlaying;
  final bool isListening;
  final String? heard;
  final PronunciationOutcome? outcome;
  final VoidCallback onPlay;
  final VoidCallback onMic;

  const _ExampleCard({
    required this.example,
    required this.isPlaying,
    required this.isListening,
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
  final String? heard;
  final PronunciationOutcome? outcome;

  const _Feedback({
    required this.isListening,
    required this.heard,
    required this.outcome,
  });

  @override
  Widget build(BuildContext context) {
    if (isListening) {
      final partial = (heard ?? '').trim();
      return _strip(
        bg: BayanColors.primary.withValues(alpha: 0.08),
        fg: BayanColors.primary,
        icon: Icons.graphic_eq_rounded,
        text: partial.isEmpty ? 'Listening… speak now' : '“$partial”',
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
