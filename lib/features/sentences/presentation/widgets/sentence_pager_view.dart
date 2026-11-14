import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/sentence_item.dart';
import '../bloc/sentence_content/sentence_content_bloc.dart';
import '../bloc/sentence_content/sentence_content_event.dart';
import '../bloc/sentence_practice/sentence_practice_bloc.dart';
import '../bloc/sentence_practice/sentence_practice_event.dart';
import '../bloc/sentence_practice/sentence_practice_state.dart';
import 'lesson_progress_header.dart';
import 'pager_controls.dart';
import 'sentence_card_large.dart';

/// Swipeable one-sentence-per-page view used by the Cards mode of the lesson
/// screen. On every page change it:
///   • stops any in-flight STT / audio to free the mic,
///   • bumps the persisted "seen" counter via [TrackSentenceSeen].
class SentencePagerView extends StatefulWidget {
  final List<SentenceItem> sentences;
  final int? playingId;
  final SentencePracticeState practiceState;
  final int subtopicId;
  final String? topicIconKey;

  const SentencePagerView({
    super.key,
    required this.sentences,
    required this.playingId,
    required this.practiceState,
    required this.subtopicId,
    required this.topicIconKey,
  });

  @override
  State<SentencePagerView> createState() => _SentencePagerViewState();
}

class _SentencePagerViewState extends State<SentencePagerView> {
  late final PageController _ctrl = PageController();
  int _currentPage = 0;

  @override
  void didUpdateWidget(covariant SentencePagerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPage >= widget.sentences.length &&
        widget.sentences.isNotEmpty) {
      _currentPage = widget.sentences.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_ctrl.hasClients) _ctrl.jumpToPage(_currentPage);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sentences = widget.sentences;
    if (sentences.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        LessonProgressHeader(
          currentOneBased: _currentPage + 1,
          total: sentences.length,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: PageView.builder(
                controller: _ctrl,
                itemCount: sentences.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (ctx, i) {
                  final s = sentences[i];
                  final practiceState = widget.practiceState;
                  final isListeningThis =
                      practiceState.activeSentenceId == s.id;
                  final practiceBloc = context.read<SentencePracticeBloc>();
                  final contentBloc = context.read<SentenceContentBloc>();
                  final attempt = practiceState.attempts[s.id];

                  return Semantics(
                    label: 'Sentence ${i + 1} of ${sentences.length}',
                    container: true,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: SentenceCardLarge(
                        sentence: s,
                        topicIconKey: widget.topicIconKey,
                        isPlaying: widget.playingId == s.id,
                        onPlayTap: () => contentBloc
                            .add(PlaySentenceAudio(sentenceId: s.id)),
                        accent: practiceState.accent,
                        speed: practiceState.speed,
                        onAccentChanged: practiceBloc.setAccent,
                        onSpeedChanged: practiceBloc.setSpeed,
                        isListening: isListeningThis,
                        armed:
                            isListeningThis && practiceState.armed,
                        partialText: isListeningThis
                            ? practiceState.partialText
                            : '',
                        attempt: attempt,
                        onMicTap: isListeningThis
                            ? () => practiceBloc
                                .add(const StopSentenceCheck())
                            : () => practiceBloc.add(
                                  StartSentenceCheck(
                                    sentenceId: s.id,
                                    targetSentence: s.english,
                                  ),
                                ),
                        onTryAgain: () => practiceBloc.add(
                          ClearSentenceAttempt(sentenceId: s.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        _PagerDivider(),
        PagerControls(
          count: sentences.length,
          current: _currentPage,
          onPrev: _currentPage == 0 ? null : () => _animate(_currentPage - 1),
          onNext: _currentPage == sentences.length - 1
              ? null
              : () => _animate(_currentPage + 1),
        ),
      ],
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    context.read<SentencePracticeBloc>().add(const StopSentenceCheck());
    context.read<SentenceContentBloc>()
      ..add(const StopSentenceAudio())
      ..add(TrackSentenceSeen(
        subtopicId: widget.subtopicId,
        oneBasedIndex: index + 1,
      ));
  }

  void _animate(int index) {
    _ctrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }
}

class _PagerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 4);
  }
}
