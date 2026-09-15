import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/audio/sound_player.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../domain/entities/phonetic_example.dart';

class PhoneticAudioPlayerBar extends StatelessWidget {
  final PhoneticExample example;
  final SoundPlayer soundPlayer;
  final VoidCallback onClose;

  const PhoneticAudioPlayerBar({
    super.key,
    required this.example,
    required this.soundPlayer,
    required this.onClose,
  });

  String _label() {
    final word = example.word;
    final phon = example.phonetic ?? '';
    return phon.isEmpty ? 'Playing "$word"' : 'Playing $phon · $word';
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final audio = soundPlayer.audioManager;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.containerPadding,
        vertical: AppConstants.spacingMd,
      ),
      decoration: const BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: BayanColors.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: StreamBuilder<PlayerState>(
          stream: audio.playerStateStream,
          builder: (context, stateSnap) {
            final isPlaying =
                stateSnap.data == PlayerState.playing || soundPlayer.isTtsActive;
            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (isPlaying) {
                      soundPlayer.pause();
                    } else {
                      soundPlayer.resume();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: BayanColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: BayanColors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _label(),
                              style: BayanTypography.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (soundPlayer.isTtsActive) ...[
                            const SizedBox(width: 6),
                            const _TtsBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      _Progress(
                        soundPlayer: soundPlayer,
                        fmt: _fmt,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: BayanColors.onSurfaceVariant,
                  ),
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final SoundPlayer soundPlayer;
  final String Function(Duration) fmt;
  const _Progress({required this.soundPlayer, required this.fmt});

  @override
  Widget build(BuildContext context) {
    if (soundPlayer.isTtsActive) {
      return const _IndeterminateBar();
    }
    final audio = soundPlayer.audioManager;
    return StreamBuilder<Duration>(
      stream: audio.durationStream,
      builder: (context, durSnap) {
        final dur = durSnap.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: audio.positionStream,
          builder: (context, posSnap) {
            final pos = posSnap.data ?? Duration.zero;
            final progress = dur.inMilliseconds == 0
                ? 0.0
                : (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: BayanColors.surfaceContainerHigh,
                    valueColor:
                        const AlwaysStoppedAnimation(BayanColors.primary),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${fmt(pos)} / ${fmt(dur)}',
                  style: BayanTypography.labelMedium.copyWith(
                    color: BayanColors.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _IndeterminateBar extends StatelessWidget {
  const _IndeterminateBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          child: const LinearProgressIndicator(
            minHeight: 4,
            backgroundColor: BayanColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(BayanColors.primary),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Speaking…',
          style: BayanTypography.labelMedium.copyWith(
            color: BayanColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TtsBadge extends StatelessWidget {
  const _TtsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: BayanColors.tertiary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        'TTS',
        style: BayanTypography.labelMedium.copyWith(
          color: BayanColors.tertiary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
