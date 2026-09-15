import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../base/extensions/context_ext.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../progress/domain/entities/grammar_subtopic_status.dart';
import '../../domain/entities/phonetic_topic.dart';
import 'bilingual_text.dart';

class PhoneticTopicTile extends StatelessWidget {
  final PhoneticTopic topic;
  final GrammarSubtopicStatus status;
  final VoidCallback onOpen;
  final bool isPlaying;
  final VoidCallback? onTogglePlay;

  const PhoneticTopicTile({
    super.key,
    required this.topic,
    required this.status,
    required this.onOpen,
    this.isPlaying = false,
    this.onTogglePlay,
  });

  bool get _isSoundTile => (topic.phoneTitle?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    // Locked tiles get a distinct treatment — no dimmed normal tile, just a
    // focal lock medallion + muted title preview.
    if (status.isLocked) return _LockedTile(topic: topic);

    if (_isSoundTile) {

      return _SoundTile(
        topic: topic,
        status: status,
        isPlaying: isPlaying,
        onOpen: onOpen,
        onTogglePlay: onTogglePlay,
      );
    }

    // Letter tiles split visually by status — mockup style.
    return switch (status) {
      GrammarSubtopicStatus.completed => _CompletedLetterTile(
          topic: topic,
          onOpen: onOpen,
        ),
      GrammarSubtopicStatus.inProgress => _InProgressLetterTile(
          topic: topic,
          onOpen: onOpen,
        ),
      _ => _NotStartedLetterTile(topic: topic, onOpen: onOpen),
    };
  }
}

class _LockedTile extends StatelessWidget {
  final PhoneticTopic topic;
  const _LockedTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            BayanColors.surfaceContainerHigh,
            BayanColors.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: BayanColors.outlineVariant,
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _LockedTextureCornerPainter()),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LockMedallion(),
                const SizedBox(height: AppConstants.spacingMd),
                Text(
                  topic.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: BayanColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockMedallion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BayanColors.onSurfaceVariant.withValues(alpha: 0.22),
            BayanColors.onSurfaceVariant.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: BayanColors.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: BayanColors.onSurface.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.lock_rounded,
        color: BayanColors.onSurfaceVariant,
        size: 26,
      ),
    );
  }
}

class _LockedTextureCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BayanColors.onSurfaceVariant.withValues(alpha: 0.05)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    const wedge = 36.0;
    for (var d = -wedge; d <= wedge; d += 10) {
      canvas.drawLine(
        Offset(size.width - wedge + d, 0),
        Offset(size.width, wedge - d),
        paint,
      );
    }
    for (var d = -wedge; d <= wedge; d += 10) {
      canvas.drawLine(
        Offset(0, size.height - wedge + d),
        Offset(wedge - d, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CompletedLetterTile extends StatelessWidget {
  final PhoneticTopic topic;
  final VoidCallback onOpen;
  const _CompletedLetterTile({required this.topic, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayanColors.primary.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        splashColor: BayanColors.primary.withValues(alpha: 0.10),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: _CheckBadge(),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _letterGlyph(topic.title),
                      style: BayanTypography.displayLarge.copyWith(
                        fontSize: 56,
                        color: BayanColors.primary,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    BilingualText(
                      en: topic.title,
                      ar: topic.titleAr,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      primary: context.textTheme.bodyLarge!.copyWith(
                        color: BayanColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      secondary: context.textTheme.bodyLarge!.copyWith(
                        color: BayanColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: BayanColors.secondary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.check_rounded,
        color: BayanColors.white,
        size: 24,
      ),
    );
  }
}

class _InProgressLetterTile extends StatelessWidget {
  final PhoneticTopic topic;
  final VoidCallback onOpen;
  const _InProgressLetterTile({required this.topic, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    return Material(
      color: BayanColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        splashColor: BayanColors.primary.withValues(alpha: 0.08),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _letterGlyph(topic.title),
                    style: BayanTypography.displayLarge.copyWith(
                      fontSize: 56,
                      color: BayanColors.primary,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  BilingualText(
                    en: topic.title,
                    ar: topic.titleAr,
                    textAlign: TextAlign.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    primary: context.textTheme.bodyMedium!.copyWith(
                        color: BayanColors.onSurface,
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w600
                    ),
                    secondary: context.textTheme.bodyLarge!.copyWith(
                        color: BayanColors.onSurface,
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w600

                    ),
                    maxLines: 1,
                  ),
                  _StartButton(
                    label: l.lessonStatusStart.toUpperCase(),
                    onTap: onOpen,
                  ),
                ],
              ),
            ),
            Positioned(
              top: AppConstants.spacingSm,
              right: AppConstants.spacingSm,
              child: _AccentDot(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: BayanColors.tertiaryContainer,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _StartButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayanColors.tertiaryContainer,
      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingSm,
          ),
          child: Text(
            label,
            style: BayanTypography.labelLarge.copyWith(
              color: BayanColors.onTertiary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotStartedLetterTile extends StatelessWidget {
  final PhoneticTopic topic;
  final VoidCallback onOpen;
  const _NotStartedLetterTile({required this.topic, required this.onOpen});

  @override
  Widget build(BuildContext context) {

    return Material(
      color: BayanColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        splashColor: BayanColors.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _letterGlyph(topic.title),
                style: BayanTypography.displayLarge.copyWith(
                  fontSize: 56,
                  color: BayanColors.primary,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              BilingualText(
                en: topic.title,
                ar: topic.titleAr,
                textAlign: TextAlign.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                primary: context.textTheme.bodyMedium!.copyWith(
                  color: BayanColors.onSurface,
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w600
                ),
                secondary: context.textTheme.bodyLarge!.copyWith(
                  color: BayanColors.onSurface,
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w600

                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  final PhoneticTopic topic;
  final GrammarSubtopicStatus status;
  final bool isPlaying;
  final VoidCallback onOpen;
  final VoidCallback? onTogglePlay;

  const _SoundTile({
    required this.topic,
    required this.status,
    required this.isPlaying,
    required this.onOpen,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    final canPlay = (topic.sound?.isNotEmpty ?? false) && onTogglePlay != null;
    final isCompleted = status.isCompleted;
    return Material(
      color: isCompleted
          ? BayanColors.primary.withValues(alpha: 0.10)
          : BayanColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        splashColor: BayanColors.primary.withValues(alpha: 0.08),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: Text(
                      topic.phoneTitle!,
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: BayanColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  if ((topic.word ?? '').isNotEmpty)
                    Text(
                      _formatWord(topic.word!),
                      style: context.textTheme.titleMedium?.copyWith(
                        color: BayanColors.onSurface,
                        height: 1.35,
                      ),
                    ),
                ],
              ),
            ),
            if (isCompleted)
              Positioned(
                top: AppConstants.spacingLg,
                right: AppConstants.spacingLg,
                child: _CheckBadge(),
              ),
            if (canPlay)
              Positioned(
                bottom: AppConstants.spacingLg,
                right: AppConstants.spacingLg,
                child: _PlayButton(
                  isPlaying: isPlaying,
                  onTap: onTogglePlay!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatWord(String raw) => raw
      .split(RegExp(r'[\n,]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .join('\n');
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _PlayButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayanColors.primary,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: BayanColors.onPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

String _letterGlyph(String title) {
  final quoted = RegExp(r"'([^']+)'").firstMatch(title);
  if (quoted != null) return quoted.group(1)!;
  const prefix = 'The Letter ';
  if (title.startsWith(prefix)) return title.substring(prefix.length).trim();
  return title.isNotEmpty ? title.characters.first : '';
}
