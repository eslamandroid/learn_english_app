import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../di/di.dart';
import '../../../../features/phonetics/presentation/bloc/pronunciation/pronunciation_bloc.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../domain/usecases/get_my_words.dart';
import '../bloc/dictionary/dictionary_bloc.dart';
import '../bloc/dictionary/dictionary_event.dart';
import '../bloc/dictionary/dictionary_state.dart';
import '../widgets/dictionary_level_filter.dart';
import '../widgets/dictionary_search_bar.dart';
import '../widgets/dictionary_word_card.dart';
import '../widgets/my_words_sheet.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<DictionaryBloc>()..add(const LoadInitialDictionary())),
        // Reused as-is from phonetics (per TASK_08 §5) — single-word check,
        // exact-match verdict is exactly what SpeechTextMatcher already does.
        BlocProvider(create: (_) => getIt<PronunciationBloc>()),
      ],
      child: Scaffold(
        backgroundColor: BayanColors.screenBg,
        appBar: AppBar(
          backgroundColor: BayanColors.screenBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 16,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Words',
                style: BayanTypography.titleLarge.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: BayanColors.onSurface,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<DictionaryBloc, DictionaryState>(
              buildWhen: (p, c) => p.myWordsCount != c.myWordsCount,
              builder: (ctx, s) => _MyWordsButton(count: s.myWordsCount),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: const _Body(),
      ),
    );
  }
}

class _MyWordsButton extends StatelessWidget {
  final int count;

  const _MyWordsButton({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: BayanColors.warnTint,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap:
              () => MyWordsSheet.show(
                context: context,
                getMyWords: getIt<GetMyWords>(),
                dictionaryBloc: context.read<DictionaryBloc>(),
                pronunciationBloc: context.read<PronunciationBloc>(),
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: BayanColors.warn, size: 16),
                const SizedBox(width: 4),
                Text(
                  'My Words',
                  style: BayanTypography.labelMedium.copyWith(
                    fontSize: 13,
                    color: BayanColors.warnFg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: BayanColors.warn, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      '$count',
                      style: BayanTypography.labelMedium.copyWith(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.removeListener(_maybeLoadMore);
    _scroll.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    final gap = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (gap < 400) {
      context.read<DictionaryBloc>().add(const DictionaryLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: DictionarySearchBar(onChanged: (q) => context.read<DictionaryBloc>().add(DictionaryQueryChanged(q))),
        ),
        BlocBuilder<DictionaryBloc, DictionaryState>(
          buildWhen: (p, c) => p.level != c.level,
          builder:
              (ctx, s) => DictionaryLevelFilter(
                selected: s.level,
                onChanged: (l) => ctx.read<DictionaryBloc>().add(DictionaryLevelChanged(l)),
              ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<DictionaryBloc, DictionaryState>(
            builder: (ctx, state) {
              if (state.status == DictionaryStatus.loading && state.words.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == DictionaryStatus.error && state.words.isEmpty) {
                return ErrorStateView(
                  message: state.errorMessage ?? 'Something went wrong',
                  onRetry: () => ctx.read<DictionaryBloc>().add(const LoadInitialDictionary()),
                );
              }
              if (state.words.isEmpty) {
                return EmptyStateView(
                  icon: Icons.search_off_rounded,
                  title: 'No matches',
                  message:
                      state.isSearching ? 'Try a different word or clear the filters.' : 'The dictionary is empty.',
                );
              }
              return ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: state.words.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (c, i) {
                  if (i >= state.words.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    );
                  }
                  final w = state.words[i];
                  return DictionaryWordCard(
                    word: w,
                    isPlaying: state.playingWordId == w.id,
                    onPlay: () => ctx.read<DictionaryBloc>().add(DictionaryPlayAudio(w)),
                    onToggleSaved: () => ctx.read<DictionaryBloc>().add(DictionaryToggleSaved(w)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
