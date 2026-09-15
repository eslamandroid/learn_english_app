// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:learn_english_app/base/network/interceptor/connectivity_interceptor.dart'
    as _i764;
import 'package:learn_english_app/base/preference/app_preferences.dart' as _i45;
import 'package:learn_english_app/base/utils/device_id_util.dart' as _i828;
import 'package:learn_english_app/core/audio/sound_cache.dart' as _i655;
import 'package:learn_english_app/core/audio/sound_player.dart' as _i552;
import 'package:learn_english_app/core/usecases/get_selected_level.dart'
    as _i906;
import 'package:learn_english_app/core/usecases/set_selected_level.dart'
    as _i333;
import 'package:learn_english_app/core/utils/audio_manager.dart' as _i371;
import 'package:learn_english_app/di/modules.dart' as _i214;
import 'package:learn_english_app/features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i533;
import 'package:learn_english_app/features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i397;
import 'package:learn_english_app/features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i154;
import 'package:learn_english_app/features/dashboard/domain/usecases/get_dashboard_stats.dart'
    as _i1026;
import 'package:learn_english_app/features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i432;
import 'package:learn_english_app/features/grammar/data/datasources/grammar_local_datasource.dart'
    as _i787;
import 'package:learn_english_app/features/grammar/data/repositories/grammar_repository_impl.dart'
    as _i220;
import 'package:learn_english_app/features/grammar/domain/repositories/grammar_repository.dart'
    as _i973;
import 'package:learn_english_app/features/grammar/domain/usecases/get_grammar_lesson.dart'
    as _i993;
import 'package:learn_english_app/features/grammar/domain/usecases/get_grammar_rule_tests.dart'
    as _i844;
import 'package:learn_english_app/features/grammar/domain/usecases/get_grammar_subtopics.dart'
    as _i707;
import 'package:learn_english_app/features/grammar/domain/usecases/get_grammar_topics.dart'
    as _i896;
import 'package:learn_english_app/features/grammar/presentation/bloc/grammar_lesson/grammar_lesson_bloc.dart'
    as _i1014;
import 'package:learn_english_app/features/grammar/presentation/bloc/grammar_topics/grammar_topics_bloc.dart'
    as _i27;
import 'package:learn_english_app/features/language/data/datasource/local/language_local_datasource.dart'
    as _i250;
import 'package:learn_english_app/features/language/data/repository/language_repository_impl.dart'
    as _i758;
import 'package:learn_english_app/features/language/domain/domain.dart'
    as _i830;
import 'package:learn_english_app/features/language/domain/repository/language_repository.dart'
    as _i901;
import 'package:learn_english_app/features/language/domain/usecase/change_language_usecase.dart'
    as _i124;
import 'package:learn_english_app/features/language/domain/usecase/get_current_language_usecase.dart'
    as _i614;
import 'package:learn_english_app/features/language/domain/usecase/get_supported_languages_usecase.dart'
    as _i385;
import 'package:learn_english_app/features/language/domain/usecase/observe_language_usecase.dart'
    as _i907;
import 'package:learn_english_app/features/language/presentation/bloc/language_bloc.dart'
    as _i935;
import 'package:learn_english_app/features/onboarding/presentation/bloc/onboarding_cubit.dart'
    as _i209;
import 'package:learn_english_app/features/phonetics/data/datasources/phonetic_local_datasource.dart'
    as _i858;
import 'package:learn_english_app/features/phonetics/data/repositories/phonetic_repository_impl.dart'
    as _i818;
import 'package:learn_english_app/features/phonetics/domain/repositories/phonetic_repository.dart'
    as _i178;
import 'package:learn_english_app/features/phonetics/domain/usecases/get_phonetic_categories.dart'
    as _i595;
import 'package:learn_english_app/features/phonetics/domain/usecases/get_phonetic_sections.dart'
    as _i735;
import 'package:learn_english_app/features/phonetics/domain/usecases/get_phonetic_topic.dart'
    as _i1071;
import 'package:learn_english_app/features/phonetics/domain/usecases/get_phonetic_topics.dart'
    as _i882;
import 'package:learn_english_app/features/phonetics/presentation/bloc/phonetic_categories/phonetic_categories_bloc.dart'
    as _i867;
import 'package:learn_english_app/features/phonetics/presentation/bloc/phonetic_detail/phonetic_detail_bloc.dart'
    as _i135;
import 'package:learn_english_app/features/phonetics/presentation/bloc/phonetic_topics/phonetic_topics_bloc.dart'
    as _i84;
import 'package:learn_english_app/features/progress/data/datasources/progress_local_datasource.dart'
    as _i52;
import 'package:learn_english_app/features/progress/data/repositories/progress_repository_impl.dart'
    as _i953;
import 'package:learn_english_app/features/progress/domain/repositories/progress_repository.dart'
    as _i900;
import 'package:learn_english_app/features/progress/domain/usecases/get_current_grammar_lesson.dart'
    as _i442;
import 'package:learn_english_app/features/progress/domain/usecases/get_grammar_progress.dart'
    as _i749;
import 'package:learn_english_app/features/progress/domain/usecases/get_phonetics_progress.dart'
    as _i699;
import 'package:learn_english_app/features/progress/domain/usecases/mark_grammar_lesson_completed.dart'
    as _i530;
import 'package:learn_english_app/features/progress/domain/usecases/mark_grammar_lesson_started.dart'
    as _i1047;
import 'package:learn_english_app/features/progress/domain/usecases/mark_phonetic_topic_completed.dart'
    as _i615;
import 'package:learn_english_app/features/progress/domain/usecases/mark_phonetic_topic_started.dart'
    as _i227;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:sqflite/sqflite.dart' as _i779;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final serviceModule = _$ServiceModule();
    final databaseModule = _$DatabaseModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => serviceModule.prefs,
      preResolve: true,
    );
    gh.factory<_i764.ConnectivityInterceptor>(
      () => _i764.ConnectivityInterceptor(),
    );
    gh.singleton<_i558.FlutterSecureStorage>(
      () => serviceModule.flutterSecureStorage,
    );
    gh.singleton<_i974.FirebaseFirestore>(() => serviceModule.firestore);
    await gh.singletonAsync<_i779.Database>(
      () => databaseModule.database,
      preResolve: true,
    );
    gh.lazySingleton<_i371.AudioManager>(
      () => _i371.AudioManager(),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i655.SoundCache>(() => _i655.SoundCache());
    gh.factory<_i209.OnboardingCubit>(
      () => _i209.OnboardingCubit(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i906.GetSelectedLevel>(
      () => _i906.GetSelectedLevel(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i333.SetSelectedLevel>(
      () => _i333.SetSelectedLevel(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i52.ProgressLocalDataSource>(
      () => _i52.ProgressLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i533.DashboardLocalDataSource>(
      () => _i533.DashboardLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i45.AppPreferences>(
      () => _i45.AppPreferences(
        gh<_i460.SharedPreferences>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i250.LanguageLocalDatasource>(
      () => _i250.LanguageLocalDatasourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i787.GrammarLocalDataSource>(
      () => _i787.GrammarLocalDataSourceImpl(gh<_i779.Database>()),
    );
    gh.lazySingleton<_i973.GrammarRepository>(
      () => _i220.GrammarRepositoryImpl(gh<_i787.GrammarLocalDataSource>()),
    );
    gh.lazySingleton<_i858.PhoneticLocalDataSource>(
      () => _i858.PhoneticLocalDataSourceImpl(gh<_i779.Database>()),
    );
    gh.lazySingleton<_i830.LanguageRepository>(
      () => _i758.LanguageRepositoryImpl(gh<_i250.LanguageLocalDatasource>()),
    );
    gh.lazySingleton<_i154.DashboardRepository>(
      () => _i397.DashboardRepositoryImpl(gh<_i533.DashboardLocalDataSource>()),
    );
    gh.lazySingleton<_i828.DeviceIdUtil>(
      () => _i828.DeviceIdUtil(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i707.GetGrammarSubtopics>(
      () => _i707.GetGrammarSubtopics(gh<_i973.GrammarRepository>()),
    );
    gh.factory<_i844.GetGrammarRuleTests>(
      () => _i844.GetGrammarRuleTests(gh<_i973.GrammarRepository>()),
    );
    gh.factory<_i896.GetGrammarTopics>(
      () => _i896.GetGrammarTopics(gh<_i973.GrammarRepository>()),
    );
    gh.factory<_i993.GetGrammarLesson>(
      () => _i993.GetGrammarLesson(gh<_i973.GrammarRepository>()),
    );
    gh.lazySingleton<_i552.SoundPlayer>(
      () => _i552.SoundPlayer(gh<_i371.AudioManager>(), gh<_i655.SoundCache>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i900.ProgressRepository>(
      () => _i953.ProgressRepositoryImpl(gh<_i52.ProgressLocalDataSource>()),
      // dispose: (i) => i.dispose(),
    );
    gh.factory<_i442.GetCurrentGrammarLesson>(
      () => _i442.GetCurrentGrammarLesson(
        gh<_i900.ProgressRepository>(),
        gh<_i973.GrammarRepository>(),
      ),
    );
    gh.lazySingleton<_i178.PhoneticRepository>(
      () => _i818.PhoneticRepositoryImpl(gh<_i858.PhoneticLocalDataSource>()),
    );
    gh.factory<_i124.ChangeLanguageUsecase>(
      () => _i124.ChangeLanguageUsecase(gh<_i901.LanguageRepository>()),
    );
    gh.factory<_i385.GetSupportedLanguagesUsecase>(
      () => _i385.GetSupportedLanguagesUsecase(gh<_i901.LanguageRepository>()),
    );
    gh.factory<_i614.GetCurrentLanguageUsecase>(
      () => _i614.GetCurrentLanguageUsecase(gh<_i901.LanguageRepository>()),
    );
    gh.factory<_i907.ObserveLanguageUsecase>(
      () => _i907.ObserveLanguageUsecase(gh<_i901.LanguageRepository>()),
    );
    gh.factory<_i530.MarkGrammarLessonCompleted>(
      () => _i530.MarkGrammarLessonCompleted(gh<_i900.ProgressRepository>()),
    );
    gh.factory<_i1047.MarkGrammarLessonStarted>(
      () => _i1047.MarkGrammarLessonStarted(gh<_i900.ProgressRepository>()),
    );
    gh.factory<_i749.GetGrammarProgress>(
      () => _i749.GetGrammarProgress(gh<_i900.ProgressRepository>()),
    );
    gh.factory<_i227.MarkPhoneticTopicStarted>(
      () => _i227.MarkPhoneticTopicStarted(gh<_i900.ProgressRepository>()),
    );
    gh.factory<_i699.GetPhoneticsProgress>(
      () => _i699.GetPhoneticsProgress(gh<_i900.ProgressRepository>()),
    );
    gh.factory<_i615.MarkPhoneticTopicCompleted>(
      () => _i615.MarkPhoneticTopicCompleted(gh<_i900.ProgressRepository>()),
    );
    gh.factory<_i27.GrammarTopicsBloc>(
      () => _i27.GrammarTopicsBloc(
        gh<_i896.GetGrammarTopics>(),
        gh<_i707.GetGrammarSubtopics>(),
        gh<_i749.GetGrammarProgress>(),
        gh<_i906.GetSelectedLevel>(),
      ),
    );
    gh.factory<_i1026.GetDashboardStats>(
      () => _i1026.GetDashboardStats(gh<_i154.DashboardRepository>()),
    );
    gh.factory<_i935.LanguageBloc>(
      () => _i935.LanguageBloc(
        gh<_i830.GetCurrentLanguageUsecase>(),
        gh<_i830.ChangeLanguageUsecase>(),
        gh<_i830.GetSupportedLanguagesUsecase>(),
        gh<_i830.ObserveLanguageUsecase>(),
      ),
    );
    gh.factory<_i1014.GrammarLessonBloc>(
      () => _i1014.GrammarLessonBloc(
        gh<_i993.GetGrammarLesson>(),
        gh<_i844.GetGrammarRuleTests>(),
        gh<_i552.SoundPlayer>(),
        gh<_i906.GetSelectedLevel>(),
        gh<_i1047.MarkGrammarLessonStarted>(),
        gh<_i530.MarkGrammarLessonCompleted>(),
      ),
    );
    gh.factory<_i882.GetPhoneticTopics>(
      () => _i882.GetPhoneticTopics(gh<_i178.PhoneticRepository>()),
    );
    gh.factory<_i1071.GetPhoneticTopic>(
      () => _i1071.GetPhoneticTopic(gh<_i178.PhoneticRepository>()),
    );
    gh.factory<_i595.GetPhoneticCategories>(
      () => _i595.GetPhoneticCategories(gh<_i178.PhoneticRepository>()),
    );
    gh.factory<_i735.GetPhoneticSections>(
      () => _i735.GetPhoneticSections(gh<_i178.PhoneticRepository>()),
    );
    gh.factory<_i135.PhoneticDetailBloc>(
      () => _i135.PhoneticDetailBloc(
        gh<_i1071.GetPhoneticTopic>(),
        gh<_i735.GetPhoneticSections>(),
        gh<_i552.SoundPlayer>(),
        gh<_i227.MarkPhoneticTopicStarted>(),
        gh<_i615.MarkPhoneticTopicCompleted>(),
        gh<_i699.GetPhoneticsProgress>(),
      ),
    );
    gh.factory<_i432.DashboardBloc>(
      () => _i432.DashboardBloc(
        gh<_i1026.GetDashboardStats>(),
        gh<_i906.GetSelectedLevel>(),
        gh<_i442.GetCurrentGrammarLesson>(),
        gh<_i900.ProgressRepository>(),
      ),
    );
    gh.factory<_i84.PhoneticTopicsBloc>(
      () => _i84.PhoneticTopicsBloc(
        gh<_i882.GetPhoneticTopics>(),
        gh<_i699.GetPhoneticsProgress>(),
        gh<_i906.GetSelectedLevel>(),
      ),
    );
    gh.factory<_i867.PhoneticCategoriesBloc>(
      () => _i867.PhoneticCategoriesBloc(
        gh<_i595.GetPhoneticCategories>(),
        gh<_i699.GetPhoneticsProgress>(),
        gh<_i178.PhoneticRepository>(),
        gh<_i906.GetSelectedLevel>(),
      ),
    );
    return this;
  }
}

class _$ServiceModule extends _i214.ServiceModule {}

class _$DatabaseModule extends _i214.DatabaseModule {}
