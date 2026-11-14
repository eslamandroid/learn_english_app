import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../features/phonetics/presentation/bloc/pronunciation/pronunciation_bloc.dart';
import '../../domain/entities/dictionary_word.dart';
import '../../domain/usecases/get_my_words.dart';
import '../bloc/dictionary/dictionary_bloc.dart';
import '../bloc/dictionary/dictionary_event.dart';
import '../bloc/dictionary/dictionary_state.dart';
import 'dictionary_word_card.dart';

/// Bottom sheet that lists every row of `my_word_list` using the same raised
/// [DictionaryWordCard] as the main list. Deleting a word dispatches
/// [DictionaryToggleSaved] against the parent [DictionaryBloc] so the main
/// list's star updates in sync.
///
/// `getMyWords.watch()` keeps the sheet live — removals (via the star on the
/// card) reflect without the user closing and reopening the sheet.
class MyWordsSheet extends StatefulWidget {
  final GetMyWords getMyWords;
  const MyWordsSheet({super.key, required this.getMyWords});

  @override
  State<MyWordsSheet> createState() => _MyWordsSheetState();

  /// Opens the sheet. The caller passes in the already-constructed blocs so
  /// the sheet's cards can read `DictionaryBloc.playingWordId` for the audio
  /// button and `PronunciationBloc.state.activeExampleId` for the mic.
  static Future<void> show({
    required BuildContext context,
    required GetMyWords getMyWords,
    required DictionaryBloc dictionaryBloc,
    required PronunciationBloc pronunciationBloc,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BayanColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: dictionaryBloc),
          BlocProvider.value(value: pronunciationBloc),
        ],
        child: MyWordsSheet(getMyWords: getMyWords),
      ),
    );
  }
}

class _MyWordsSheetState extends State<MyWordsSheet> {
  late final Stream<List<DictionaryWord>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = widget.getMyWords.watch();
  }

  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mediaHeight * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Handle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: BayanColors.warning, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'My Words',
                    style: BayanTypography.titleLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: BayanColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: BayanColors.onSurfaceVariant,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: BayanColors.outlineVariant),
            Flexible(
              child: StreamBuilder<List<DictionaryWord>>(
                stream: _stream,
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final words = snap.data!;
                  if (words.isEmpty) return const _Empty();
                  return _List(words: words);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pulls the `playingWordId` and the toggle handler from the ambient
/// [DictionaryBloc] — reuses exactly the same [DictionaryWordCard] the main
/// screen renders. Removing a word from the sheet goes through the same
/// [DictionaryToggleSaved] event, so main-list star state refreshes via the
/// repository's `savedChanges` broadcast.
class _List extends StatelessWidget {
  final List<DictionaryWord> words;
  const _List({required this.words});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DictionaryBloc, DictionaryState>(
      buildWhen: (p, c) => p.playingWordId != c.playingWordId,
      builder: (ctx, state) {
        final bloc = ctx.read<DictionaryBloc>();
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: words.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (c, i) {
            final w = words[i];
            return DictionaryWordCard(
              word: w,
              isPlaying: state.playingWordId == w.id,
              onPlay: () => bloc.add(DictionaryPlayAudio(w)),
              onToggleSaved: () => bloc.add(DictionaryToggleSaved(w)),
            );
          },
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: BayanColors.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_border_rounded,
            size: 56,
            color: BayanColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            "You haven't saved any words yet.",
            textAlign: TextAlign.center,
            style: BayanTypography.bodyMedium.copyWith(
              color: BayanColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the star next to any word to save it here.',
            textAlign: TextAlign.center,
            style: BayanTypography.bodySmall.copyWith(
              color: BayanColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
