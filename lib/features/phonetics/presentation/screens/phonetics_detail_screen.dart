import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/base/base.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../domain/entities/phonetic_section.dart';
import '../bloc/phonetic_detail/phonetic_detail_bloc.dart';
import '../bloc/phonetic_detail/phonetic_detail_event.dart';
import '../bloc/phonetic_detail/phonetic_detail_state.dart';
import '../widgets/phonetic_complete_bar.dart';
import '../widgets/phonetic_detail_loaded_body.dart';
import '../widgets/phonetic_hero_card.dart';
import '../widgets/phonetic_loading_skeleton.dart';

class PhoneticsDetailScreen extends StatelessWidget {
  final int topicId;

  const PhoneticsDetailScreen({super.key, required this.topicId});

  static String? _heroSound(List<PhoneticSection>? sections) {
    if (sections == null) return null;
    for (final s in sections) {
      if ((s.sound ?? '').isNotEmpty) return s.sound;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PhoneticDetailBloc>()
        ..add(LoadPhoneticDetail(topicId: topicId, accent: 'us')),
      child: Scaffold(
        backgroundColor: BayanColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: CustomBackButton(onClicked: () => context.pop()),
          toolbarHeight: 80,
          title: BlocBuilder<PhoneticDetailBloc, PhoneticDetailState>(
            builder: (context, state) {
              final loaded = state is PhoneticDetailLoaded ? state : null;
              final heroSound = _heroSound(loaded?.sections);
              final topic = loaded?.topic;
              return topic == null
                  ? const SizedBox.shrink()
                  : PhoneticHeroCard(
                      topic: topic,
                      soundAsset: heroSound,
                      isPlaying: loaded?.playingSound ?? false,
                      onTogglePlay: (loaded == null || heroSound == null)
                          ? null
                          : () {
                              final bloc = context.read<PhoneticDetailBloc>();
                              if (loaded.playingSound) {
                                bloc.add(const StopTopicSound());
                              } else {
                                bloc.add(
                                  PlayTopicSound(assetName: heroSound),
                                );
                              }
                            },
                    ).paddingTBSE(bottom: 10);
            },
          ),
        ),
        body: BlocBuilder<PhoneticDetailBloc, PhoneticDetailState>(
          builder: (context, state) {
            return switch (state) {
              PhoneticDetailInitial() ||
              PhoneticDetailLoading() =>
                const PhoneticLoadingSkeleton(),
              PhoneticDetailError(:final message) => ErrorStateView(
                  message: message,
                  onRetry: () => context.read<PhoneticDetailBloc>().add(
                        LoadPhoneticDetail(topicId: topicId, accent: 'us'),
                      ),
                ),
              PhoneticDetailLoaded() => PhoneticDetailLoadedBody(state: state),
              _ => const SizedBox.shrink(),
            };
          },
        ),
        bottomNavigationBar:
            BlocBuilder<PhoneticDetailBloc, PhoneticDetailState>(
          builder: (context, state) {
            if (state is! PhoneticDetailLoaded) return const SizedBox.shrink();
            return PhoneticCompleteBar(
              isCompleted: state.isCompleted,
              onMarkComplete: () => context
                  .read<PhoneticDetailBloc>()
                  .add(const FinishPhoneticTopic()),
            );
          },
        ),
      ),
    );
  }
}
