import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/get_selected_level.dart';
import '../../../../../shared/enums/cefr_level.dart';
import '../../../../progress/domain/entities/phonetics_progress.dart';
import '../../../../progress/domain/usecases/get_phonetics_progress.dart';
import '../../../domain/usecases/get_phonetic_topics.dart';
import 'phonetic_topics_event.dart';
import 'phonetic_topics_state.dart';

@injectable
class PhoneticTopicsBloc
    extends Bloc<PhoneticTopicsEvent, PhoneticTopicsState> {
  final GetPhoneticTopics _getTopics;
  final GetPhoneticsProgress _getProgress;
  final GetSelectedLevel _getLevel;

  StreamSubscription<PhoneticsProgress>? _progressSub;

  CefrLevel get level => _getLevel.current();

  PhoneticTopicsBloc(this._getTopics, this._getProgress, this._getLevel)
      : super(const PhoneticTopicsInitial()) {
    on<LoadPhoneticTopics>(_onLoad);
    on<PhoneticsTopicsProgressChanged>(_onProgressChanged);

    _progressSub = _getProgress.watch().listen(
          (p) => add(PhoneticsTopicsProgressChanged(progress: p)),
        );
  }

  Future<void> _onLoad(
    LoadPhoneticTopics event,
    Emitter<PhoneticTopicsState> emit,
  ) async {
    emit(const PhoneticTopicsLoading());
    final topicsEither =
        await _getTopics.execute(categoryId: event.categoryId);
    final progress = (await _getProgress.execute()).fold(
      (_) => PhoneticsProgress.empty,
      (p) => p,
    );
    topicsEither.fold(
      (exception) => emit(PhoneticTopicsError(message: exception.toString())),
      (topics) => emit(PhoneticTopicsLoaded(
        topics: topics,
        progress: progress,
      )),
    );
  }

  void _onProgressChanged(
    PhoneticsTopicsProgressChanged event,
    Emitter<PhoneticTopicsState> emit,
  ) {
    final s = state;
    if (s is! PhoneticTopicsLoaded) return;
    emit(s.copyWith(progress: event.progress));
  }

  @override
  Future<void> close() async {
    await _progressSub?.cancel();
    return super.close();
  }
}
