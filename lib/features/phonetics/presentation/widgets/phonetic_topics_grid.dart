import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_player.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../di/di.dart';
import '../../../progress/domain/entities/phonetics_progress.dart';
import '../../domain/entities/phonetic_topic.dart';
import 'phonetic_topic_tile.dart';

class PhoneticTopicsGrid extends StatefulWidget {
  final List<PhoneticTopic> topics;
  final PhoneticsProgress progress;
  final void Function(PhoneticTopic topic) onOpen;
  final List<Widget> header;

  const PhoneticTopicsGrid({
    super.key,
    required this.topics,
    required this.progress,
    required this.onOpen,
    this.header = const [],
  });

  @override
  State<PhoneticTopicsGrid> createState() => _PhoneticTopicsGridState();
}

class _PhoneticTopicsGridState extends State<PhoneticTopicsGrid> {
  final SoundPlayer _player = getIt<SoundPlayer>();
  StreamSubscription<SoundSource>? _completionSub;
  int? _playingId;

  @override
  void initState() {
    super.initState();
    _completionSub = _player.completionStream.listen((_) {
      if (mounted) setState(() => _playingId = null);
    });
  }

  @override
  void dispose() {
    _completionSub?.cancel();
    _player.stop();
    super.dispose();
  }

  Future<void> _toggle(PhoneticTopic topic) async {
    final sound = topic.sound;
    if (sound == null || sound.isEmpty) return;

    if (_playingId == topic.id) {
      await _player.stop();
      if (mounted) setState(() => _playingId = null);
      return;
    }

    setState(() => _playingId = topic.id);
    try {
      await _player.playAsset('sounds/$sound.m4a');
    } catch (_) {
      if (mounted) setState(() => _playingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.topics.map((t) => t.id).toList();
    return CustomScrollView(
      slivers: [
        for (final w in widget.header) SliverToBoxAdapter(child: w),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.containerPadding,
            0,
            AppConstants.containerPadding,
            AppConstants.containerPadding,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppConstants.cardGap,
              crossAxisSpacing: AppConstants.cardGap,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final topic = widget.topics[i];
                final status = widget.progress.statusFor(topic.id, order);
                return PhoneticTopicTile(
                  topic: topic,
                  status: status,
                  onOpen: () => widget.onOpen(topic),
                  isPlaying: _playingId == topic.id,
                  onTogglePlay: () => _toggle(topic),
                );
              },
              childCount: widget.topics.length,
            ),
          ),
        ),
      ],
    );
  }
}
