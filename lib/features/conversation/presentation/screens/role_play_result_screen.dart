import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../domain/entities/conversation_line.dart';
import '../bloc/role_play/role_play_state.dart';
import '../widgets/character_avatar.dart';

/// Static result screen pushed as a plain MaterialPageRoute (per TASK 13 §1
/// — not a GoRoute, since there's nothing deep-linkable about it).
///
/// Reads [results] + [lines] passed in from the player; the player already
/// owns the [RolePlayBloc] and keeps it alive so "Try again" can restart
/// in-place without re-fetching lines.
class RolePlayResultScreen extends StatelessWidget {
  final String character;
  final List<ConversationLine> lines;
  final Map<int, RoleLineResult> results;
  final VoidCallback onContinue;
  final VoidCallback onTryAgain;

  const RolePlayResultScreen({
    super.key,
    required this.character,
    required this.lines,
    required this.results,
    required this.onContinue,
    required this.onTryAgain,
  });

  /// Threshold for the "pass" colour — matches the one SentenceAssessor
  /// uses internally so the visual language stays consistent with the
  /// per-line pills during play.
  static const double _passColorThreshold = 0.7;

  int get _firstTryCount =>
      results.values.where((r) => r.passedFirstTry).length;

  double get _averageScore {
    if (results.isEmpty) return 0;
    final sum = results.values.fold<double>(0, (a, r) => a + r.bestScore);
    return sum / results.length;
  }

  List<ConversationLine> get _userLines =>
      lines.where((l) => l.character == character).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final avg = _averageScore;
    final avgPct = (avg * 100).round();
    final passColour =
        avg >= _passColorThreshold ? BayanColors.successFg : BayanColors.warnFg;

    return Scaffold(
      backgroundColor: BayanColors.screenBg,
      appBar: AppBar(
        backgroundColor: BayanColors.screenBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  Center(child: CharacterAvatar(name: character, size: 92)),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Role-play complete',
                      style: BayanTypography.labelLarge.copyWith(
                        fontSize: 13,
                        color: BayanColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Nicely done, $character!',
                      style: BayanTypography.headlineLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: BayanColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SummaryCard(
                    avgPct: avgPct,
                    avgColour: passColour,
                    firstTry: _firstTryCount,
                    total: _userLines.length,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your lines',
                    style: BayanTypography.labelLarge.copyWith(
                      fontSize: 13,
                      color: BayanColors.textMuted,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final l in _userLines) ...[
                    _LineRow(line: l, result: results[l.id]),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: onTryAgain,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: BayanColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          'Try again',
                          style: BayanTypography.labelLarge.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: BayanColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: onContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: BayanColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: BayanTypography.labelLarge.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int avgPct;
  final Color avgColour;
  final int firstTry;
  final int total;

  const _SummaryCard({
    required this.avgPct,
    required this.avgColour,
    required this.firstTry,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BayanColors.onSurface.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              label: 'Average score',
              value: '$avgPct%',
              valueColour: avgColour,
            ),
          ),
          Container(width: 1, height: 44, color: BayanColors.divider),
          Expanded(
            child: _SummaryStat(
              label: 'First-try lines',
              value: '$firstTry / $total',
              valueColour: BayanColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColour;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.valueColour,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: BayanTypography.headlineLarge.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: valueColour,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: BayanTypography.bodySmall.copyWith(
            color: BayanColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LineRow extends StatelessWidget {
  final ConversationLine line;
  final RoleLineResult? result;

  const _LineRow({required this.line, required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;
    final passedFirst = r?.passedFirstTry ?? false;
    final attempts = r?.attempts ?? 0;
    final pct = ((r?.bestScore ?? 0) * 100).round();
    final chipBg =
        passedFirst ? BayanColors.successTint : BayanColors.warnTint;
    final chipFg = passedFirst ? BayanColors.successFg : BayanColors.warnFg;
    final chipIcon =
        passedFirst ? Icons.check_rounded : Icons.refresh_rounded;
    final chipLabel =
        passedFirst ? '$pct% · first try' : '$attempts tries · $pct%';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BayanColors.divider, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              line.english,
              style: BayanTypography.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: BayanColors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(chipIcon, size: 13, color: chipFg),
                const SizedBox(width: 4),
                Text(
                  chipLabel,
                  style: BayanTypography.labelMedium.copyWith(
                    color: chipFg,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
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
