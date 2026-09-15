import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/sound_player.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../bloc/phonetic_detail/phonetic_detail_bloc.dart';
import '../bloc/phonetic_detail/phonetic_detail_event.dart';
import '../bloc/phonetic_detail/phonetic_detail_state.dart';
import 'phonetic_accent_bar.dart';
import 'phonetic_audio_player_bar.dart';
import 'phonetic_section_widget.dart';

/// Scrollable body of the phonetic detail screen: accent bar + sections list +
/// playing-example bar. Wired to [PhoneticDetailBloc] for all interactions.
class PhoneticDetailLoadedBody extends StatelessWidget {
  final PhoneticDetailLoaded state;

  const PhoneticDetailLoadedBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PhoneticDetailBloc>();
    final playingId = state.playingExample?.id;
    final sections = state.sections;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.containerPadding,
                  AppConstants.spacingMd,
                  AppConstants.containerPadding,
                  AppConstants.spacingMd,
                ),
                sliver: SliverToBoxAdapter(
                  child: PhoneticAccentBar(
                    currentAccent: state.currentAccent,
                    onChanged: (accent) =>
                        bloc.add(ChangeAccent(accent: accent)),
                  ),
                ),
              ),
              if (sections.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: Icons.menu_book_outlined,
                    title: 'No lessons yet',
                    message: 'Try switching accent to find more content.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.containerPadding,
                    0,
                    AppConstants.containerPadding,
                    AppConstants.spacingLg,
                  ),
                  sliver: SliverList.separated(
                    itemCount: sections.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppConstants.spacingMd),
                    itemBuilder: (_, i) => PhoneticSectionWidget(
                      section: sections[i],
                      playingExampleId: playingId,
                      onPlayExample: (ex) {
                        if (playingId == ex.id) {
                          bloc.add(const StopExampleAudio());
                        } else {
                          bloc.add(PlayExampleAudio(example: ex));
                        }
                      },
                      isSoundPlaying: state.playingSound,
                      onToggleSound: (asset) {
                        if (state.playingSound) {
                          bloc.add(const StopTopicSound());
                        } else {
                          bloc.add(PlayTopicSound(assetName: asset));
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (state.playingExample != null)
          PhoneticAudioPlayerBar(
            example: state.playingExample!,
            soundPlayer: getIt<SoundPlayer>(),
            onClose: () => bloc.add(const StopExampleAudio()),
          ),
      ],
    );
  }
}
