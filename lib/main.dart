import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_english_app/base/utils/bloc_observer.dart';
import 'package:learn_english_app/base/utils/firebase_service.dart';
import 'package:learn_english_app/features/language/presentation/bloc/language_bloc.dart';
import 'package:learn_english_app/features/language/presentation/bloc/language_event.dart';
import 'package:learn_english_app/features/language/presentation/bloc/language_state.dart';
import 'package:learn_english_app/core/router/app_router.dart';
import 'package:learn_english_app/core/theme/bayan_theme.dart';
import 'package:learn_english_app/core/utils/content_language.dart';
import 'package:learn_english_app/core/utils/phoenix.dart';
import 'package:learn_english_app/core/utils/voice_preferences.dart';
import 'package:learn_english_app/l10n/share_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base/constants/environment/environment_config.dart';
import 'base/constants/environment/environment_manager.dart';
import 'di/config.dart';
import 'di/di.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await FirebaseService.init(
        navigatorKey: AppRouter.rootNavigatorKey,
        enableCrashlytics: true,
        enableAnalytics: true,
      );
      try {
        GoogleFonts.config.allowRuntimeFetching = false;
        await _initializeEnvironment();
        await _initializeServices();
        Bloc.observer = MyBlocObserver();

        runApp(const Phoenix(child: MyApp()));
      } catch (e) {
        _handleInitializationError(e);
      }
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true, reason: 'runZonedGuarded');
    },
  );
}

Future<void> _initializeEnvironment() async {
  try {
    await EnvironmentConfig.initialize();

    await EnvironmentManager.instance.validateEnvironment();

    _logEnvironmentInfo();
  } catch (e) {
    throw Exception('Failed to initialize environment: $e');
  }
}

Future<void> _initializeServices() async {
  try {
    await AppDiConfig.getInstance().init();
    final prefs = getIt<SharedPreferences>();
    AppContentLanguage.instance.bind(prefs);
    AppVoicePreferences.instance.bind(prefs);
  } catch (e) {
    throw Exception('Failed to initialize services: $e');
  }
}

void _logEnvironmentInfo() {
  if (EnvironmentConfig.isLoggingEnabled) {
    final envSummary = EnvironmentManager.instance.getEnvironmentSummary();
    debugPrint('🌍 Environment initialized: ${envSummary['manager']['environment']}');
    debugPrint('🔧 Flavor: ${envSummary['manager']['flavor']}');
    debugPrint('📡 API Base URL: ${envSummary['config']['api']}');
    debugPrint('✅ Environment health: ${envSummary['health']['isHealthy']}');

    if (envSummary['health']['warnings'].isNotEmpty) {
      debugPrint('⚠️  Warnings: ${envSummary['health']['warnings']}');
    }
  }
}

void _handleInitializationError(dynamic error) {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('App Initialization Failed', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Error: $error', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  getIt<LanguageBloc>()
                    ..add(const LoadCurrentLanguageEvent())
                    ..add(const ObserveLanguageChangesEvent()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 800),
        minTextAdapt: true,
        builder: (context, w) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder:
                (context, languageState) => MaterialApp.router(
                  title: 'Bayan English',
                  debugShowCheckedModeBanner: false,
                  themeMode: ThemeMode.light,
                  themeAnimationDuration: Duration.zero,
                  theme: BayanTheme.light(),
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  locale: Locale(languageState.currentLanguage?.code ?? EnvironmentConfig.defaultLocale),
                  supportedLocales: EnvironmentConfig.supportedLocales.map((locale) => Locale(locale)).toList(),
                  routerConfig: AppRouter.router,
                ),
          );
        },
      ),
    );
  }
}
