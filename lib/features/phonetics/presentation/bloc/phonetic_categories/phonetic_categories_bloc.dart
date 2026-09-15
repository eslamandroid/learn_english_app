import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/get_selected_level.dart';
import '../../../../../shared/enums/cefr_level.dart';
import '../../../../progress/domain/entities/phonetics_progress.dart';
import '../../../../progress/domain/usecases/get_phonetics_progress.dart';
import '../../../domain/repositories/phonetic_repository.dart';
import '../../../domain/usecases/get_phonetic_categories.dart';
import 'phonetic_categories_event.dart';
import 'phonetic_categories_state.dart';

@injectable
class PhoneticCategoriesBloc
    extends Bloc<PhoneticCategoriesEvent, PhoneticCategoriesState> {
  final GetPhoneticCategories _getCategories;
  final GetPhoneticsProgress _getProgress;
  final PhoneticRepository _phoneticRepo;
  final GetSelectedLevel _getLevel;

  StreamSubscription<PhoneticsProgress>? _progressSub;

  CefrLevel get level => _getLevel.current();

  PhoneticCategoriesBloc(
    this._getCategories,
    this._getProgress,
    this._phoneticRepo,
    this._getLevel,
  ) : super(const PhoneticCategoriesInitial()) {
    on<LoadPhoneticCategories>(_onLoad);
    on<PhoneticsProgressChanged>(_onProgressChanged);

    _progressSub = _getProgress.watch().listen(
          (p) => add(PhoneticsProgressChanged(progress: p)),
        );
  }

  Future<void> _onLoad(
    LoadPhoneticCategories event,
    Emitter<PhoneticCategoriesState> emit,
  ) async {
    emit(const PhoneticCategoriesLoading());

    final catFut = _getCategories.execute();
    // Cheap aggregate — single SQL.
    final indexFut = _phoneticRepo.getTopicIdsByCategory();
    final progressFut = _getProgress.execute();

    final catEither = await catFut;
    final index = await indexFut;
    final progressEither = await progressFut;

    catEither.fold(
      (exception) =>
          emit(PhoneticCategoriesError(message: exception.toString())),
      (categories) {
        final progress = progressEither.fold(
          (_) => PhoneticsProgress.empty,
          (p) => p,
        );
        emit(PhoneticCategoriesLoaded(
          categories: categories,
          topicIdsByCategory: index,
          progress: progress,
        ));
      },
    );
  }

  void _onProgressChanged(
    PhoneticsProgressChanged event,
    Emitter<PhoneticCategoriesState> emit,
  ) {
    final s = state;
    if (s is! PhoneticCategoriesLoaded) return;
    emit(s.copyWith(progress: event.progress));
  }

  @override
  Future<void> close() async {
    await _progressSub?.cancel();
    return super.close();
  }
}
