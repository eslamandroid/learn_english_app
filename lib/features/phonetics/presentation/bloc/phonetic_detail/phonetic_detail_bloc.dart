import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/audio/sound_player.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/network/cdn_config.dart';
import '../../../../progress/domain/entities/phonetics_progress.dart';
import '../../../../progress/domain/usecases/get_phonetics_progress.dart';
import '../../../../progress/domain/usecases/mark_phonetic_topic_completed.dart';
import '../../../../progress/domain/usecases/mark_phonetic_topic_started.dart';
import '../../../domain/entities/phonetic_topic.dart';
import '../../../domain/usecases/get_phonetic_sections.dart';
import '../../../domain/usecases/get_phonetic_topic.dart';
import 'phonetic_detail_event.dart';
import 'phonetic_detail_state.dart';

@injectable
class PhoneticDetailBloc
    extends Bloc<PhoneticDetailEvent, PhoneticDetailState> {
  final GetPhoneticTopic _getTopic;
  final GetPhoneticSections _getSections;
  final SoundPlayer _soundPlayer;
  final MarkPhoneticTopicStarted _markStarted;
  final MarkPhoneticTopicCompleted _markCompleted;
  final GetPhoneticsProgress _getProgress;

  int? _currentTopicId;
  PhoneticTopic? _topicCache;
  PhoneticsProgress _progress = PhoneticsProgress.empty;
  StreamSubscription<SoundSource>? _completionSub;
  StreamSubscription<PhoneticsProgress>? _progressSub;

  PhoneticDetailBloc(
    this._getTopic,
    this._getSections,
    this._soundPlayer,
    this._markStarted,
    this._markCompleted,
    this._getProgress,
  ) : super(const PhoneticDetailInitial()) {
    on<LoadPhoneticDetail>(_onLoad);
    on<ChangeAccent>(_onChangeAccent);
    on<PlayExampleAudio>(_onPlayAudio);
    on<StopExampleAudio>(_onStopAudio);
    on<PlayTopicSound>(_onPlayTopicSound);
    on<StopTopicSound>(_onStopTopicSound);
    on<FinishPhoneticTopic>(_onFinish);
    on<PhoneticDetailProgressChanged>(_onProgressChanged);

    _completionSub = _soundPlayer.completionStream.listen((source) {
      if (source == SoundSource.asset) {
        add(const StopTopicSound());
      } else {
        add(const StopExampleAudio());
      }
    });
    _progressSub = _getProgress.watch().listen(
          (p) => add(PhoneticDetailProgressChanged(progress: p)),
        );
  }

  Future<void> _onLoad(
    LoadPhoneticDetail event,
    Emitter<PhoneticDetailState> emit,
  ) async {
    emit(const PhoneticDetailLoading());
    _currentTopicId = event.topicId;

    final cached = _topicCache;
    final needsTopicFetch = cached == null || cached.id != event.topicId;

    final topicFut =
        needsTopicFetch ? _getTopic.execute(id: event.topicId) : null;
    final sectionsFut = _getSections.execute(
      topicId: event.topicId,
      accent: event.accent,
    );

    final sectionsEither = await sectionsFut;
    if (topicFut != null) {
      final topicEither = await topicFut;
      _topicCache = topicEither.fold((_) => null, (t) => t);
    }

    sectionsEither.fold(
      (exception) =>
          emit(PhoneticDetailError(message: exception.toString())),
      (sections) {
        emit(PhoneticDetailLoaded(
          topic: _topicCache,
          sections: sections,
          currentAccent: event.accent,
          isCompleted: _progress.isCompleted(event.topicId),
        ));
        // Fire-and-forget — flips the progress store to "in progress" so
        // the topics screen + dashboard reflect it.
        _markStarted.execute(topicId: event.topicId);
      },
    );
  }

  Future<void> _onFinish(
    FinishPhoneticTopic event,
    Emitter<PhoneticDetailState> emit,
  ) async {
    final id = _currentTopicId;
    if (id == null) return;
    await _markCompleted.execute(topicId: id);
  }

  void _onProgressChanged(
    PhoneticDetailProgressChanged event,
    Emitter<PhoneticDetailState> emit,
  ) {
    _progress = event.progress;
    final s = state;
    final tid = _currentTopicId;
    if (s is! PhoneticDetailLoaded || tid == null) return;
    emit(s.copyWith(isCompleted: event.progress.isCompleted(tid)));
  }

  Future<void> _onChangeAccent(
    ChangeAccent event,
    Emitter<PhoneticDetailState> emit,
  ) async {
    final topicId = _currentTopicId;
    if (topicId == null) return;
    await _soundPlayer.stop();
    add(LoadPhoneticDetail(topicId: topicId, accent: event.accent));
  }

  Future<void> _onPlayAudio(
    PlayExampleAudio event,
    Emitter<PhoneticDetailState> emit,
  ) async {
    final s = state;
    if (s is! PhoneticDetailLoaded) return;

    emit(s.copyWith(playingExample: event.example, playingSound: false));

    final voiceKey = s.currentAccent == 'uk'
        ? AppConstants.voiceUkFemale
        : AppConstants.voiceUsFemale;
    final cdnUrl =
        CdnConfig.phoneticExampleAudio(event.example.id, voiceKey);
    final locale = s.currentAccent == 'uk' ? 'en-GB' : 'en-US';

    try {
      await _soundPlayer.play(
        cdnUrl: cdnUrl,
        fallbackText: event.example.word,
        locale: locale,
      );
    } catch (_) {
      add(const StopExampleAudio());
    }
  }

  Future<void> _onStopAudio(
    StopExampleAudio event,
    Emitter<PhoneticDetailState> emit,
  ) async {
    final s = state;
    if (s is! PhoneticDetailLoaded) return;
    await _soundPlayer.stop();
    emit(s.copyWith(clearPlayingExample: true));
  }

  Future<void> _onPlayTopicSound(
    PlayTopicSound event,
    Emitter<PhoneticDetailState> emit,
  ) async {
    final s = state;
    if (s is! PhoneticDetailLoaded) return;

    emit(s.copyWith(playingSound: true, clearPlayingExample: true));

    try {
      await _soundPlayer.playAsset('sounds/${event.assetName}.m4a');
    } catch (_) {
      add(const StopTopicSound());
    }
  }

  Future<void> _onStopTopicSound(
    StopTopicSound event,
    Emitter<PhoneticDetailState> emit,
  ) async {
    final s = state;
    if (s is! PhoneticDetailLoaded) return;
    await _soundPlayer.stop();
    emit(s.copyWith(playingSound: false));
  }

  @override
  Future<void> close() async {
    await _completionSub?.cancel();
    await _progressSub?.cancel();
    await _soundPlayer.stop();
    return super.close();
  }
}
