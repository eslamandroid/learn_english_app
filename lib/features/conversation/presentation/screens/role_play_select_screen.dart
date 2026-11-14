import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../domain/entities/conversation_line.dart';
import '../../domain/usecases/get_conversation_lines.dart';
import '../widgets/role_play_character_card.dart';

/// Character selection step: fetches the lesson's lines once, extracts the
/// unique speakers in order of appearance, lets the user tap one, then
/// pushes [AppRoutes.rolePlayPlayer].
///
/// Edge case: a lesson that happens to have a single speaker (very rare)
/// shows a "Not enough speakers" state instead of a one-card trap — the task
/// spec suggested filtering these out at the lesson-row level, but the row
/// doesn't carry character info and querying every lesson's lines up-front
/// would be wasteful. Handling it here is cheaper and gracefully degrades.
class RolePlaySelectScreen extends StatefulWidget {
  final int categoryId;
  final int lessonId;
  final String? lessonTitle;

  const RolePlaySelectScreen({
    super.key,
    required this.categoryId,
    required this.lessonId,
    this.lessonTitle,
  });

  @override
  State<RolePlaySelectScreen> createState() => _RolePlaySelectScreenState();
}

class _RolePlaySelectScreenState extends State<RolePlaySelectScreen> {
  late Future<List<ConversationLine>> _future;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ConversationLine>> _load() async {
    final usecase = getIt<GetConversationLines>();
    final result = await usecase.execute(lessonId: widget.lessonId);
    return result.fold(
      (err) => throw Exception(err.toString()),
      (lines) => lines,
    );
  }

  List<_CharacterSummary> _summarize(List<ConversationLine> lines) {
    final counts = <String, int>{};
    final order = <String>[];
    for (final l in lines) {
      counts[l.character] = (counts[l.character] ?? 0) + 1;
      if (!order.contains(l.character)) order.add(l.character);
    }
    return [
      for (final c in order)
        _CharacterSummary(name: c, lineCount: counts[c] ?? 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              'ROLE-PLAY',
              style: BayanTypography.labelMedium.copyWith(
                fontSize: 11,
                color: BayanColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1 * 11,
              ),
            ),
            Text(
              widget.lessonTitle ?? 'Choose a character',
              style: BayanTypography.titleLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: BayanColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<ConversationLine>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ErrorStateView(
              message: snap.error?.toString() ?? 'Could not load this lesson.',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final lines = snap.data ?? const <ConversationLine>[];
          final summaries = _summarize(lines);

          if (summaries.length < 2) {
            return _NotEnoughSpeakers(
              onBack: () => context.pop(),
            );
          }

          return SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    children: [
                      _InfoBanner(),
                      const SizedBox(height: 16),
                      Text(
                        'Pick who you want to play',
                        style: BayanTypography.labelLarge.copyWith(
                          fontSize: 13,
                          color: BayanColors.textMuted,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final s in summaries) ...[
                        RolePlayCharacterCard(
                          name: s.name,
                          lineCount: s.lineCount,
                          isSelected: _selected == s.name,
                          onTap: () => setState(() => _selected = s.name),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                _StartBar(
                  selectedName: _selected,
                  onStart: _selected == null
                      ? null
                      : () => context.push(
                            AppRoutes.rolePlayPlayer(
                              widget.categoryId,
                              widget.lessonId,
                              _selected!,
                            ),
                            extra: widget.lessonTitle,
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CharacterSummary {
  final String name;
  final int lineCount;
  _CharacterSummary({required this.name, required this.lineCount});
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: BayanColors.primaryTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: BayanColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "You'll need to say each of your lines well enough to continue. "
              'You can retry as many times as you like.',
              style: BayanTypography.bodySmall.copyWith(
                color: BayanColors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartBar extends StatelessWidget {
  final String? selectedName;
  final VoidCallback? onStart;
  const _StartBar({required this.selectedName, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final enabled = onStart != null;
    final label =
        selectedName == null ? 'Pick a character' : 'Start as $selectedName';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onStart,
          style: FilledButton.styleFrom(
            backgroundColor: enabled
                ? BayanColors.primary
                : BayanColors.primary.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          icon: const Icon(Icons.play_arrow_rounded, size: 22),
          label: Text(
            label,
            style: BayanTypography.labelLarge.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotEnoughSpeakers extends StatelessWidget {
  final VoidCallback onBack;
  const _NotEnoughSpeakers({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.record_voice_over_outlined,
              size: 64,
              color: BayanColors.textMuted.withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          Text(
            'This lesson has only one speaker.',
            textAlign: TextAlign.center,
            style: BayanTypography.titleLarge.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: BayanColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Role-play needs at least two characters to work. Try a different '
            'lesson from the list.',
            textAlign: TextAlign.center,
            style: BayanTypography.bodyMedium.copyWith(
              color: BayanColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onBack,
            style: FilledButton.styleFrom(
              backgroundColor: BayanColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text('Back to lessons'),
          ),
        ],
      ),
    );
  }
}

