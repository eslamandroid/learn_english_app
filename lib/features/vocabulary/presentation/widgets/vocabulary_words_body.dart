import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/enums/cefr_level.dart';
import '../../../phonetics/presentation/bloc/pronunciation/pronunciation_bloc.dart';
import '../../../phonetics/presentation/bloc/pronunciation/pronunciation_event.dart';
import '../../../phonetics/presentation/bloc/pronunciation/pronunciation_state.dart';
import '../bloc/vocabulary_words/vocabulary_words_bloc.dart';
import '../bloc/vocabulary_words/vocabulary_words_event.dart';
import '../bloc/vocabulary_words/vocabulary_words_state.dart';
import 'vocabulary_word_detail_view.dart';

/// Swipeable pager over the words in one subtopic — each page renders the
/// single-word detail view. Reads pronunciation state from [PronunciationBloc]
/// so the mic UI reflects the current attempt. Progress ("N of M") lives in
/// the screen's header now, not here.
class VocabularyWordsBody extends StatefulWidget {
  final VocabularyWordsLoaded state;
  final CefrLevel level;

  const VocabularyWordsBody({
    super.key,
    required this.state,
    required this.level,
  });

  @override
  State<VocabularyWordsBody> createState() => _VocabularyWordsBodyState();
}

class _VocabularyWordsBodyState extends State<VocabularyWordsBody> {
  late final PageController _controller = PageController(
    initialPage: widget.state.currentIndex,
  );

  @override
  void didUpdateWidget(covariant VocabularyWordsBody old) {
    super.didUpdateWidget(old);
    final target = widget.state.currentIndex;
    if (_controller.hasClients &&
        (_controller.page?.round() ?? target) != target) {
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.words.isEmpty) {
      return const Center(child: Text('No words in this subtopic.'));
    }

    return BlocBuilder<PronunciationBloc, PronunciationState>(
      builder: (context, pState) {
        return PageView.builder(
          controller: _controller,
          itemCount: widget.state.words.length,
          onPageChanged: (i) {
            context.read<VocabularyWordsBloc>().add(
                  ChangeVocabularyWordIndex(index: i),
                );
            // Kill any in-flight recognition on the previous word so it
            // doesn't leak an attempt into the next word.
            context.read<PronunciationBloc>().add(
                  const StopPronunciationCheck(),
                );
          },
          itemBuilder: (context, i) {
            final word = widget.state.words[i];
            final isPlaying = i == widget.state.currentIndex &&
                widget.state.playingWordId == word.id;
            final isExamplePlaying = i == widget.state.currentIndex &&
                widget.state.playingExampleWordId == word.id;
            final isListening = pState.activeExampleId == word.id;
            final partial = isListening ? pState.partialText : '';
            final attempt = pState.attempts[word.id];

            return VocabularyWordDetailView(
              word: word,
              level: widget.level,
              isPlaying: isPlaying,
              accent: widget.state.accent,
              speed: widget.state.speed,
              onPlayToggle: () => context.read<VocabularyWordsBloc>().add(
                    PlayVocabularyWord(wordId: word.id),
                  ),
              isExamplePlaying: isExamplePlaying,
              onExamplePlayToggle: () => context
                  .read<VocabularyWordsBloc>()
                  .add(PlayVocabularyExample(wordId: word.id)),
              onAccentChanged: (a) => context.read<VocabularyWordsBloc>().add(
                    SetVocabularyWordAccent(accent: a),
                  ),
              onSpeedChanged: (sp) => context.read<VocabularyWordsBloc>().add(
                    SetVocabularyWordSpeed(speed: sp),
                  ),
              isListening: isListening,
              partialText: partial,
              attempt: attempt,
              onMicPressed: () => _onMicPressed(
                context,
                word.id,
                word.word,
                isListening,
              ),
            );
          },
        );
      },
    );
  }

  void _onMicPressed(
    BuildContext context,
    int wordId,
    String target,
    bool isListening,
  ) {
    final pBloc = context.read<PronunciationBloc>();
    if (isListening) {
      pBloc.add(const StopPronunciationCheck());
      return;
    }
    // Speaking and listening at the same time confuses the STT engine — stop
    // any audio playback before opening the mic.
    context.read<VocabularyWordsBloc>().add(const StopVocabularyWord());
    pBloc.add(StartPronunciationCheck(exampleId: wordId, targetWord: target));
  }
}
