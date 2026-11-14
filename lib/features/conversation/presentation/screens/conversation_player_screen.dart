import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/utils/content_language.dart';
import '../../../../core/utils/conversation_view_mode_preference.dart';
import '../../../../di/di.dart';
import '../../../../features/sentences/presentation/bloc/sentence_practice/sentence_practice_bloc.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../bloc/conversation_player/conversation_player_bloc.dart';
import '../bloc/conversation_player/conversation_player_event.dart';
import '../bloc/conversation_player/conversation_player_state.dart';
import '../widgets/conversation_view_mode_toggle.dart';
import 'conversation_chat_body.dart';
import 'conversation_pager_body.dart';

/// Entry screen for a conversation lesson. Picks between the Chat body and
/// the Pager body based on [ConversationViewModePreference]. Owns the two
/// blocs (player + reused sentence-practice for the mic) so both bodies see
/// the same instance when the user toggles between them.
class ConversationPlayerScreen extends StatelessWidget {
  final int lessonId;
  final String? lessonTitle;

  const ConversationPlayerScreen({
    super.key,
    required this.lessonId,
    this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ConversationPlayerBloc>()
            ..add(LoadConversationLines(lessonId: lessonId)),
        ),
        // Reused unmodified from Task 06 — exact same StartSentenceCheck
        // event, same SentenceAssessor under the hood. One instance per
        // player screen so a single active mic across the whole lesson.
        BlocProvider(create: (_) => getIt<SentencePracticeBloc>()),
      ],
      child: Scaffold(
        backgroundColor: BayanColors.screenBg,
        appBar: AppBar(
          backgroundColor: BayanColors.screenBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: BayanColors.onSurface,
            onPressed: () => context.pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TALK',
                style: BayanTypography.labelMedium.copyWith(
                  fontSize: 11,
                  color: BayanColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1 * 11,
                ),
              ),
              Text(
                lessonTitle ?? 'Lesson',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BayanTypography.titleLarge.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: BayanColors.onSurface,
                ),
              ),
            ],
          ),
          actions: [
            const _ArabicToggleButton(),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: ConversationViewModeToggle(),
            ),
          ],
        ),
        body: BlocBuilder<ConversationPlayerBloc, ConversationPlayerState>(
          builder: (context, state) {
            if (state.status == ConversationPlayerStatus.loading ||
                state.status == ConversationPlayerStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ConversationPlayerStatus.error) {
              return ErrorStateView(
                message:
                    state.errorMessage ?? 'Could not load this conversation',
                onRetry: () => context
                    .read<ConversationPlayerBloc>()
                    .add(LoadConversationLines(lessonId: lessonId)),
              );
            }
            if (state.lines.isEmpty) {
              return Center(
                child: Text(
                  'This lesson has no lines yet.',
                  style: BayanTypography.bodyMedium.copyWith(
                    color: BayanColors.textMuted,
                  ),
                ),
              );
            }
            return ValueListenableBuilder<ConversationViewMode>(
              valueListenable: ConversationViewModePreference.instance.mode,
              builder: (context, mode, _) {
                return mode == ConversationViewMode.chat
                    ? ConversationChatBody(lessonId: lessonId)
                    : ConversationPagerBody(lessonId: lessonId);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ArabicToggleButton extends StatelessWidget {
  const _ArabicToggleButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppContentLanguage.instance.showArabic,
      builder: (ctx, visible, _) => IconButton(
        tooltip: visible ? 'Hide Arabic' : 'Show Arabic',
        onPressed: () =>
            AppContentLanguage.instance.setShowArabic(!visible),
        icon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: visible
                ? BayanColors.primary
                : BayanColors.primaryTint,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'ع',
            style: BayanTypography.labelLarge.copyWith(
              fontFamily: BayanTypography.arabicFontFamily,
              color: visible ? Colors.white : BayanColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
