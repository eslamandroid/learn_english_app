import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/cdn_config.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/utils/voice_preferences.dart';
import '../../../../shared/enums/cefr_level.dart';
import '../../../../shared/enums/playback_speed.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../../phonetics/domain/entities/pronunciation_outcome.dart';
import '../../domain/entities/vocabulary_word.dart';

/// Full-screen detail view for a single vocabulary word — hero image + level
/// chip, bilingual title with IPA pill, a practice card that groups audio
/// playback + STT pronunciation check + accent/speed controls, and an
/// example sentence. The prev/save/next row lives in the screen's bottom
/// nav bar, not here.
class VocabularyWordDetailView extends StatelessWidget {
  final VocabularyWord word;
  final CefrLevel level;

  // Audio playback
  final bool isPlaying;
  final bool isExamplePlaying;
  final VoiceAccent accent;
  final PlaybackSpeed speed;
  final VoidCallback onPlayToggle;
  final VoidCallback onExamplePlayToggle;
  final ValueChanged<VoiceAccent> onAccentChanged;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;

  // Pronunciation check (STT)
  final bool isListening;
  final String partialText;
  final PronunciationAttempt? attempt;
  final VoidCallback onMicPressed;

  const VocabularyWordDetailView({
    super.key,
    required this.word,
    required this.level,
    required this.isPlaying,
    required this.isExamplePlaying,
    required this.accent,
    required this.speed,
    required this.onPlayToggle,
    required this.onExamplePlayToggle,
    required this.onAccentChanged,
    required this.onSpeedChanged,
    required this.isListening,
    required this.partialText,
    required this.attempt,
    required this.onMicPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.containerPadding,
        0,
        AppConstants.containerPadding,
        AppConstants.spacingXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroCard(word: word, level: level),
          const SizedBox(height: AppConstants.spacingMd),
          _PracticeCard(
            isPlaying: isPlaying,
            isListening: isListening,
            accent: accent,
            speed: speed,
            partialText: partialText,
            attempt: attempt,
            onPlay: onPlayToggle,
            onMic: onMicPressed,
            onAccentChanged: onAccentChanged,
            onSpeedChanged: onSpeedChanged,
          ),
          if (word.usage.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingMd),
            _UsageCard(
              usage: word.usage,
              usageAr: word.wordAr,
              isPlaying: isExamplePlaying,
              onPlay: onExamplePlayToggle,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Hero (image + title inside one elevated card) ──────────────────────────

class _HeroCard extends StatelessWidget {
  final VocabularyWord word;
  final CefrLevel level;
  const _HeroCard({required this.word, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: BayanColors.onSurface.withValues(alpha: .07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _HeroImage(word: word, level: level),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _Title(word: word),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final VocabularyWord word;
  final CefrLevel level;
  const _HeroImage({required this.word, required this.level});

  @override
  Widget build(BuildContext context) {
    final imageUrl = word.imageResourceId.isEmpty
        ? null
        : CdnConfig.wordImage(word.imageResourceId);
    return AspectRatio(
      aspectRatio: 10 / 4,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            child: imageUrl == null
                ? _placeholder()
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _placeholder(),
                    errorWidget: (_, __, ___) => _placeholder(),
                  ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: _LevelChip(level: level),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: BayanColors.surfaceContainerHigh,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 64,
          color: BayanColors.onSurfaceVariant,
        ),
      );
}

class _LevelChip extends StatelessWidget {
  final CefrLevel level;
  const _LevelChip({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: BayanColors.onSurface.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            '${level.label} · ${level.description}',
            style: BayanTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final VocabularyWord word;
  const _Title({required this.word});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          word.word,
          textAlign: TextAlign.center,
          style: BayanTypography.headlineLarge.copyWith(
            color: BayanColors.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 30,
            height: 1.15,
          ),
        ),
        if (word.wordAr.isNotEmpty) ...[
          const SizedBox(height: 6),
          ArabicVisibility(
            child: Text(
              word.wordAr,
              textAlign: TextAlign.center,
              style: BayanTypography.headlineMedium.copyWith(
                color: BayanColors.onSurface,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        if (word.phonetic.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: BayanColors.primary.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Text(
              word.phonetic,
              style: BayanTypography.bodyMedium.copyWith(
                color: BayanColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Practice card (listen + speak + accent + speed + feedback) ─────────────

class _PracticeCard extends StatelessWidget {
  final bool isPlaying;
  final bool isListening;
  final VoiceAccent accent;
  final PlaybackSpeed speed;
  final String partialText;
  final PronunciationAttempt? attempt;
  final VoidCallback onPlay;
  final VoidCallback onMic;
  final ValueChanged<VoiceAccent> onAccentChanged;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;

  const _PracticeCard({
    required this.isPlaying,
    required this.isListening,
    required this.accent,
    required this.speed,
    required this.partialText,
    required this.attempt,
    required this.onPlay,
    required this.onMic,
    required this.onAccentChanged,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingMd,
        AppConstants.spacingMd,
        AppConstants.spacingMd,
        AppConstants.spacingSm + 4,
      ),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: BayanColors.outlineVariant.withValues(alpha: .65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PracticeHeader(),
          const SizedBox(height: AppConstants.spacingMd),
          _ActionRow(
            isPlaying: isPlaying,
            isListening: isListening,
            onPlay: onPlay,
            onMic: onMic,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _ControlStrip(
            accent: accent,
            speed: speed,
            onAccentChanged: onAccentChanged,
            onSpeedChanged: onSpeedChanged,
          ),
          const SizedBox(height: AppConstants.spacingSm + 4),
          Divider(
            height: 1,
            color: BayanColors.outlineVariant.withValues(alpha: .55),
          ),
          const SizedBox(height: AppConstants.spacingSm + 2),
          _FeedbackLine(
            isListening: isListening,
            partialText: partialText,
            attempt: attempt,
          ),
        ],
      ),
    );
  }
}

class _PracticeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.school_rounded,
          size: 18,
          color: BayanColors.primary.withValues(alpha: .85),
        ),
        const SizedBox(width: 8),
        Text(
          'Listen & repeat',
          style: BayanTypography.labelLarge.copyWith(
            color: BayanColors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Text(
          'Hear it, then say it',
          style: BayanTypography.bodySmall.copyWith(
            color: BayanColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Two big circular action buttons side by side, each with a caption below —
/// same visual weight so learners see they're equally important.
class _ActionRow extends StatelessWidget {
  final bool isPlaying;
  final bool isListening;
  final VoidCallback onPlay;
  final VoidCallback onMic;

  const _ActionRow({
    required this.isPlaying,
    required this.isListening,
    required this.onPlay,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionColumn(
          filled: isPlaying,
          icon: isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
          label: 'Listen',
          color: BayanColors.primary,
          tooltip: isPlaying ? 'Stop' : 'Play word',
          onTap: onPlay,
        ),
        _ActionColumn(
          filled: isListening,
          icon: isListening ? Icons.stop_rounded : Icons.mic_rounded,
          label: 'Speak',
          color: isListening ? BayanColors.error : BayanColors.secondary,
          tooltip: isListening ? 'Stop listening' : 'Practice speaking',
          onTap: onMic,
        ),
      ],
    );
  }
}

class _ActionColumn extends StatelessWidget {
  final bool filled;
  final IconData icon;
  final String label;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionColumn({
    required this.filled,
    required this.icon,
    required this.label,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Tooltip(
          message: tooltip,
          child: Material(
            color: filled ? color : color.withValues(alpha: .12),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 60,
                height: 60,
                child: Icon(
                  icon,
                  color: filled ? Colors.white : color,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: BayanTypography.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

/// Two side-by-side segmented toggles: accent (US/UK) and speed (Slow/Normal).
class _ControlStrip extends StatelessWidget {
  final VoiceAccent accent;
  final PlaybackSpeed speed;
  final ValueChanged<VoiceAccent> onAccentChanged;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;

  const _ControlStrip({
    required this.accent,
    required this.speed,
    required this.onAccentChanged,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SegmentedPill<VoiceAccent>(
            label: 'Accent',
            options: const [
              _PillOption(value: VoiceAccent.us, label: 'US'),
              _PillOption(value: VoiceAccent.uk, label: 'UK'),
            ],
            selected: accent,
            onChanged: onAccentChanged,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: _SegmentedPill<PlaybackSpeed>(
            label: 'Speed',
            options: [
              for (final s in PlaybackSpeed.values)
                _PillOption(value: s, label: s.label),
            ],
            selected: speed,
            onChanged: onSpeedChanged,
          ),
        ),
      ],
    );
  }
}

class _PillOption<T> {
  final T value;
  final String label;
  const _PillOption({required this.value, required this.label});
}

/// Generic segmented pill used by both accent and speed toggles — a small
/// caption above (`Accent` / `Speed`), then a pill row of options where the
/// selected one is filled in the surface color for contrast.
class _SegmentedPill<T> extends StatelessWidget {
  final String label;
  final List<_PillOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const _SegmentedPill({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: BayanTypography.labelMedium.copyWith(
              color: BayanColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              fontSize: 10,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: BayanColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          child: Row(
            children: [
              for (final option in options)
                Expanded(
                  child: _PillSegment(
                    label: option.label,
                    selected: option.value == selected,
                    onTap: () => onChanged(option.value),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PillSegment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PillSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          selected ? BayanColors.surfaceContainerLowest : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: BayanTypography.labelMedium.copyWith(
              color: selected
                  ? BayanColors.primary
                  : BayanColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Feedback line ──────────────────────────────────────────────────────────

class _FeedbackLine extends StatelessWidget {
  final bool isListening;
  final String partialText;
  final PronunciationAttempt? attempt;

  const _FeedbackLine({
    required this.isListening,
    required this.partialText,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    if (isListening) {
      final partial = partialText.trim();
      return _line(
        icon: Icons.graphic_eq_rounded,
        color: BayanColors.primary,
        text: partial.isEmpty ? 'Listening… say the word' : '"$partial"',
      );
    }

    final att = attempt;
    if (att == null) {
      return _line(
        icon: Icons.mic_none_rounded,
        color: BayanColors.onSurfaceVariant,
        text: 'Tap the mic and say the word.',
      );
    }

    return switch (att.outcome) {
      PronunciationOutcome.correct => _line(
          icon: Icons.check_circle_rounded,
          color: BayanColors.success,
          text: 'Great! That sounds right.',
        ),
      PronunciationOutcome.incorrect => _line(
          icon: Icons.refresh_rounded,
          color: BayanColors.error,
          text: att.heard.trim().isEmpty
              ? 'Not quite — try again.'
              : 'Heard "${att.heard.trim()}" — try again.',
        ),
      PronunciationOutcome.noSpeech => _line(
          icon: Icons.hearing_disabled_rounded,
          color: BayanColors.warning,
          text: "Didn't catch that — try again.",
        ),
      PronunciationOutcome.denied => _line(
          icon: Icons.mic_off_rounded,
          color: BayanColors.error,
          text: 'Microphone permission is needed to practice.',
        ),
      PronunciationOutcome.unavailable => _line(
          icon: Icons.error_outline_rounded,
          color: BayanColors.error,
          text: 'Speech recognition is unavailable on this device.',
        ),
    };
  }

  Widget _line({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: BayanTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Usage / example ────────────────────────────────────────────────────────

class _UsageCard extends StatelessWidget {
  final String usage;
  final String usageAr;
  final bool isPlaying;
  final VoidCallback onPlay;

  const _UsageCard({
    required this.usage,
    required this.usageAr,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingMd,
        AppConstants.spacingSm + 4,
        AppConstants.spacingSm + 4,
        AppConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 16,
                color: BayanColors.primary.withValues(alpha: .85),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'EXAMPLE',
                  style: BayanTypography.labelMedium.copyWith(
                    color: BayanColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: onPlay,
                tooltip: isPlaying ? 'Stop example' : 'Listen to example',
                icon: Icon(
                  isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            '“$usage”',
            style: BayanTypography.bodyLarge.copyWith(
              color: BayanColors.onSurface,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (usageAr.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingSm),
            ArabicVisibility(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '"$usageAr"',
                  textAlign: TextAlign.right,
                  style: BayanTypography.bodyMedium.copyWith(
                    color: BayanColors.onSurfaceVariant,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
