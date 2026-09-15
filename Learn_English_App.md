# Bayan English - Complete App Development Guide

> A professional, bilingual English learning app for Arabic speakers.
> Built with Flutter | Clean Architecture | BLoC | SQLite + CloudFront CDN

---

## Table of Contents

1. [Clean Architecture Overview](#1-clean-architecture-overview)
2. [Tech Stack](#2-tech-stack)
3. [Project Structure](#3-project-structure)
4. [Dependency Injection](#4-dependency-injection)
5. [Design System - Bayan Blue](#5-design-system---bayan-blue)
6. [Core Layer](#6-core-layer)
7. [Database Schema & ER Map](#7-database-schema--er-map)
8. [CDN & Asset Management](#8-cdn--asset-management)
9. [Feature: Phonetics](#9-feature-phonetics)
10. [Feature: Grammar](#10-feature-grammar)
11. [Feature: Vocabulary](#11-feature-vocabulary)
12. [Feature: Sentences](#12-feature-sentences)
13. [Feature: Conversations](#13-feature-conversations)
14. [Feature: Word List](#14-feature-word-list)
15. [Feature: Dashboard](#15-feature-dashboard)
16. [Feature: Onboarding](#16-feature-onboarding)
17. [Feature: Profile & Settings](#17-feature-profile--settings)
18. [Shared / Common](#18-shared--common)
19. [Navigation](#19-navigation)
20. [Localization & RTL](#20-localization--rtl)
21. [Gamification & Progress](#21-gamification--progress)
22. [Performance Optimization](#22-performance-optimization)
23. [Testing Strategy](#23-testing-strategy)
24. [Release & Deployment](#24-release--deployment)
25. [Implementation Phases](#25-implementation-phases)

---

## 1. Clean Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│  ┌───────────┐   ┌───────────┐   ┌───────────────────────┐     │
│  │   Screen   │──▶│   BLoC    │──▶│   Widgets             │     │
│  │ (Pages)    │   │ (Cubit)   │   │ (Reusable Components) │     │
│  └───────────┘   └─────┬─────┘   └───────────────────────┘     │
│                        │ calls                                  │
├────────────────────────┼────────────────────────────────────────┤
│                  DOMAIN LAYER                                   │
│  ┌───────────┐   ┌─────┴─────┐   ┌───────────────────────┐     │
│  │  Entity    │   │  UseCase  │──▶│  Repository            │     │
│  │ (pure)     │   │ (business │   │  (abstract contract)   │     │
│  │            │   │  logic)   │   │                        │     │
│  └───────────┘   └───────────┘   └───────────┬───────────┘     │
│                                               │ implements      │
├───────────────────────────────────────────────┼─────────────────┤
│                      DATA LAYER                │                 │
│  ┌───────────────────┐   ┌────────────────────┴──────────┐     │
│  │  DataSource        │   │  Repository Implementation    │     │
│  │  (SQLite, CDN,     │   │  (implements domain contract) │     │
│  │   SharedPrefs)     │   │                               │     │
│  └─────────┬─────────┘   └───────────────────────────────┘     │
│            │                                                    │
│  ┌─────────┴─────────┐                                         │
│  │  Model             │                                         │
│  │  (DB ↔ Entity      │                                         │
│  │   mappers)         │                                         │
│  └───────────────────┘                                         │
└─────────────────────────────────────────────────────────────────┘
```

### Rules

| Layer | Depends On | Never Depends On |
|---|---|---|
| **Presentation** | Domain | Data |
| **Domain** | Nothing | Presentation, Data |
| **Data** | Domain | Presentation |

### Data Flow

```
User Action → Screen → BLoC → UseCase → Repository (abstract)
                                              ↓ (injected)
                                    RepositoryImpl → DataSource → SQLite / CDN
                                              ↓
                                         Model → Entity
                                              ↓
                                    BLoC (emit state) → Screen (rebuild UI)
```

---

## 2. Tech Stack

| Layer | Technology | Why |
|---|---|---|
| **Framework** | Flutter 3.x | Single codebase iOS & Android |
| **Language** | Dart 3.x | Null safety, sealed classes, pattern matching |
| **State** | `flutter_bloc` + `equatable` | Predictable, testable, separation of concerns |
| **DI** | `get_it` + `injectable` | Compile-safe service locator |
| **Database** | `sqflite` | Direct SQLite, no code gen overhead |
| **Network Images** | `cached_network_image` | CDN image caching |
| **Audio** | `just_audio` + `audio_session` | Streaming, caching, background play |
| **Navigation** | `go_router` | Declarative, deep linking |
| **Local Storage** | `shared_preferences` | User settings, streaks |
| **Functional** | `fpdart` | `Either<AppException, T>` for error handling |
| **Animations** | `flutter_animate` / Lottie | Micro-interactions |
| **Fonts** | `Be Vietnam Pro` | Bilingual legibility |
| **Icons** | Material Symbols Rounded | Friendly, professional |

---

## 3. Project Structure

```
lib/
├── main.dart                                # Entry point, init DI
├── app.dart                                 # MaterialApp, theme, router
│
├── core/
│   ├── network/
│   │   └── cdn_config.dart                  # CloudFront base URL + helpers
│   ├── database/
│   │   └── database_helper.dart             # SQLite open/copy from assets
│   ├── theme/
│   │   ├── bayan_theme.dart
│   │   ├── bayan_colors.dart
│   │   └── bayan_typography.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── app_routes.dart
│   ├── usecases/
│   │   └── params.dart                      # Common UseCase param DTOs
│   ├── l10n/
│   │   ├── app_en.arb
│   │   └── app_ar.arb
│   └── utils/
│       ├── audio_manager.dart               # @lazySingleton audio player
│       └── rtl_helper.dart
│
├── di/
│   ├── di.dart                              # final GetIt getIt = GetIt.instance + @injectableInit
│   ├── modules.dart                         # @module abstract classes (SharedPrefs, Database, ...)
│   └── di.config.dart                       # GENERATED by build_runner – do not edit
│
│
│ ┌──────────────────────────────────────────────────────────────────┐
│ │                     FEATURES (Clean Architecture)                │
│ └──────────────────────────────────────────────────────────────────┘
│
├── features/
│   │
│   ├── phonetics/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── phonetic_category.dart
│   │   │   │   ├── phonetic_topic.dart
│   │   │   │   ├── phonetic_section.dart
│   │   │   │   ├── phonetic_example.dart
│   │   │   │   ├── phonetic_data_item.dart
│   │   │   │   └── phonetic_table_item.dart
│   │   │   ├── repositories/
│   │   │   │   └── phonetic_repository.dart          # abstract
│   │   │   └── usecases/
│   │   │       ├── get_phonetic_categories.dart
│   │   │       ├── get_phonetic_topics.dart
│   │   │       ├── get_phonetic_sections.dart
│   │   │       └── get_phonetic_examples.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── phonetic_category_model.dart
│   │   │   │   ├── phonetic_topic_model.dart
│   │   │   │   ├── phonetic_section_model.dart
│   │   │   │   ├── phonetic_example_model.dart
│   │   │   │   ├── phonetic_data_item_model.dart
│   │   │   │   └── phonetic_table_item_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── phonetic_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── phonetic_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── phonetic_categories/
│   │       │   │   ├── phonetic_categories_bloc.dart
│   │       │   │   ├── phonetic_categories_event.dart
│   │       │   │   └── phonetic_categories_state.dart
│   │       │   ├── phonetic_topics/
│   │       │   │   ├── phonetic_topics_bloc.dart
│   │       │   │   ├── phonetic_topics_event.dart
│   │       │   │   └── phonetic_topics_state.dart
│   │       │   └── phonetic_detail/
│   │       │       ├── phonetic_detail_bloc.dart
│   │       │       ├── phonetic_detail_event.dart
│   │       │       └── phonetic_detail_state.dart
│   │       ├── screens/
│   │       │   ├── phonetics_categories_screen.dart
│   │       │   ├── phonetics_topics_screen.dart
│   │       │   └── phonetics_detail_screen.dart
│   │       └── widgets/
│   │           ├── phonetic_category_card.dart
│   │           ├── ipa_table_widget.dart
│   │           ├── phonetic_example_tile.dart
│   │           └── accent_toggle.dart
│   │
│   ├── grammar/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── grammar_topic.dart
│   │   │   │   ├── grammar_subtopic.dart
│   │   │   │   ├── grammar_rule.dart
│   │   │   │   ├── grammar_rule_description.dart
│   │   │   │   ├── grammar_rule_example.dart
│   │   │   │   └── grammar_test.dart
│   │   │   ├── repositories/
│   │   │   │   └── grammar_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_grammar_topics.dart
│   │   │       ├── get_grammar_subtopics.dart
│   │   │       ├── get_grammar_lesson.dart
│   │   │       └── get_grammar_test.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── grammar_topic_model.dart
│   │   │   │   ├── grammar_subtopic_model.dart
│   │   │   │   ├── grammar_rule_model.dart
│   │   │   │   ├── grammar_rule_description_model.dart
│   │   │   │   ├── grammar_rule_example_model.dart
│   │   │   │   └── grammar_test_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── grammar_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── grammar_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── grammar_topics/
│   │       │   │   ├── grammar_topics_bloc.dart
│   │       │   │   ├── grammar_topics_event.dart
│   │       │   │   └── grammar_topics_state.dart
│   │       │   ├── grammar_lesson/
│   │       │   │   ├── grammar_lesson_bloc.dart
│   │       │   │   ├── grammar_lesson_event.dart
│   │       │   │   └── grammar_lesson_state.dart
│   │       │   └── grammar_test/
│   │       │       ├── grammar_test_bloc.dart
│   │       │       ├── grammar_test_event.dart
│   │       │       └── grammar_test_state.dart
│   │       ├── screens/
│   │       │   ├── grammar_topics_screen.dart
│   │       │   ├── grammar_subtopics_screen.dart
│   │       │   ├── grammar_lesson_screen.dart
│   │       │   └── grammar_test_screen.dart
│   │       └── widgets/
│   │           ├── rule_card.dart
│   │           ├── description_widget.dart
│   │           ├── example_highlight.dart
│   │           └── grammar_quiz_widget.dart
│   │
│   ├── vocabulary/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── voca_topic.dart
│   │   │   │   ├── voca_subtopic.dart
│   │   │   │   └── vocabulary_word.dart
│   │   │   ├── repositories/
│   │   │   │   └── vocabulary_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_vocabulary_topics.dart
│   │   │       ├── get_vocabulary_subtopics.dart
│   │   │       ├── get_vocabulary_words.dart
│   │   │       ├── search_vocabulary.dart
│   │   │       └── toggle_favorite_word.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── voca_topic_model.dart
│   │   │   │   ├── voca_subtopic_model.dart
│   │   │   │   └── vocabulary_word_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── vocabulary_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── vocabulary_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── vocabulary_topics/
│   │       │   │   ├── vocabulary_topics_bloc.dart
│   │       │   │   ├── vocabulary_topics_event.dart
│   │       │   │   └── vocabulary_topics_state.dart
│   │       │   ├── vocabulary_words/
│   │       │   │   ├── vocabulary_words_bloc.dart
│   │       │   │   ├── vocabulary_words_event.dart
│   │       │   │   └── vocabulary_words_state.dart
│   │       │   └── vocabulary_search/
│   │       │       └── vocabulary_search_cubit.dart
│   │       ├── screens/
│   │       │   ├── vocabulary_topics_screen.dart
│   │       │   ├── vocabulary_subtopics_screen.dart
│   │       │   ├── vocabulary_list_screen.dart
│   │       │   └── word_detail_screen.dart
│   │       └── widgets/
│   │           ├── topic_grid_card.dart
│   │           ├── word_card.dart
│   │           ├── word_image.dart
│   │           └── audio_play_button.dart
│   │
│   ├── sentences/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── sentence_topic.dart
│   │   │   │   ├── sentence_subtopic.dart
│   │   │   │   └── sentence_content.dart
│   │   │   ├── repositories/
│   │   │   │   └── sentence_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_sentence_topics.dart
│   │   │       ├── get_sentence_subtopics.dart
│   │   │       ├── get_sentence_contents.dart
│   │   │       └── check_sentence_answer.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── sentence_topic_model.dart
│   │   │   │   ├── sentence_subtopic_model.dart
│   │   │   │   └── sentence_content_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── sentence_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── sentence_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── sentence_topics/
│   │       │   │   ├── sentence_topics_bloc.dart
│   │       │   │   ├── sentence_topics_event.dart
│   │       │   │   └── sentence_topics_state.dart
│   │       │   └── sentence_practice/
│   │       │       ├── sentence_practice_bloc.dart
│   │       │       ├── sentence_practice_event.dart
│   │       │       └── sentence_practice_state.dart
│   │       ├── screens/
│   │       │   ├── sentence_topics_screen.dart
│   │       │   ├── sentence_subtopics_screen.dart
│   │       │   └── sentence_practice_screen.dart
│   │       └── widgets/
│   │           ├── word_scramble_widget.dart
│   │           ├── sentence_result_card.dart
│   │           └── sentence_audio_player.dart
│   │
│   ├── conversations/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── conversation_block.dart
│   │   │   │   ├── conversation_lesson.dart
│   │   │   │   └── conversation_sentence.dart
│   │   │   ├── repositories/
│   │   │   │   └── conversation_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_conversation_blocks.dart
│   │   │       ├── get_conversation_lessons.dart
│   │   │       └── get_conversation_sentences.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── conversation_block_model.dart
│   │   │   │   ├── conversation_lesson_model.dart
│   │   │   │   └── conversation_sentence_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── conversation_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── conversation_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── conversation_blocks/
│   │       │   │   ├── conversation_blocks_bloc.dart
│   │       │   │   ├── conversation_blocks_event.dart
│   │       │   │   └── conversation_blocks_state.dart
│   │       │   └── conversation_player/
│   │       │       ├── conversation_player_bloc.dart
│   │       │       ├── conversation_player_event.dart
│   │       │       └── conversation_player_state.dart
│   │       ├── screens/
│   │       │   ├── conversation_blocks_screen.dart
│   │       │   ├── conversation_lessons_screen.dart
│   │       │   └── conversation_player_screen.dart
│   │       └── widgets/
│   │           ├── chat_bubble.dart
│   │           ├── audio_timeline.dart
│   │           └── phonetic_overlay.dart
│   │
│   ├── word_list/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── word_list_entry.dart
│   │   │   │   └── my_word.dart
│   │   │   ├── repositories/
│   │   │   │   └── word_list_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_word_list_by_level.dart
│   │   │       ├── search_word_list.dart
│   │   │       ├── add_to_my_words.dart
│   │   │       └── remove_from_my_words.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── word_list_entry_model.dart
│   │   │   │   └── my_word_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── word_list_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── word_list_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── word_list/
│   │       │   │   ├── word_list_bloc.dart
│   │       │   │   ├── word_list_event.dart
│   │       │   │   └── word_list_state.dart
│   │       │   └── my_words/
│   │       │       └── my_words_cubit.dart
│   │       ├── screens/
│   │       │   ├── word_list_levels_screen.dart
│   │       │   └── word_list_search_screen.dart
│   │       └── widgets/
│   │           └── word_list_tile.dart
│   │
│   ├── dashboard/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── dashboard_stats.dart
│   │   │   ├── repositories/
│   │   │   │   └── dashboard_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_dashboard_stats.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── dashboard_stats_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── dashboard_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── dashboard_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── dashboard_bloc.dart
│   │       │   ├── dashboard_event.dart
│   │       │   └── dashboard_state.dart
│   │       ├── screens/
│   │       │   └── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── daily_progress_card.dart
│   │           ├── streak_widget.dart
│   │           └── module_grid.dart
│   │
│   ├── onboarding/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── onboarding_cubit.dart
│   │       ├── screens/
│   │       │   └── onboarding_screen.dart
│   │       └── widgets/
│   │           ├── onboarding_page.dart
│   │           └── level_selection_card.dart
│   │
│   ├── profile/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_profile.dart
│   │   │   ├── repositories/
│   │   │   │   └── profile_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_user_profile.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_profile_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── profile_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── profile_cubit.dart
│   │       ├── screens/
│   │       │   ├── profile_screen.dart
│   │       │   └── achievements_screen.dart
│   │       └── widgets/
│   │           ├── stats_card.dart
│   │           └── achievement_badge.dart
│   │
│   └── settings/
│       └── presentation/
│           ├── bloc/
│           │   └── settings_cubit.dart
│           ├── screens/
│           │   └── settings_screen.dart
│           └── widgets/
│               └── setting_tile.dart
│
└── shared/
    ├── widgets/
    │   ├── bayan_app_bar.dart
    │   ├── bayan_bottom_nav.dart
    │   ├── bayan_card.dart
    │   ├── bayan_button.dart
    │   ├── progress_ring.dart
    │   ├── audio_player_widget.dart
    │   ├── accent_selector.dart
    │   ├── loading_shimmer.dart
    │   ├── error_widget.dart
    │   └── empty_state.dart
    ├── enums/
    │   └── voice_accent.dart
    └── extensions/
        ├── context_extensions.dart
        └── string_extensions.dart
```

---

## 4. Dependency Injection

### 4.1 pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Architecture
  flutter_bloc: ^8.1.0
  equatable: ^2.0.5
  fpdart: ^1.1.1
  get_it: ^7.6.0
  injectable: ^2.3.0

  # Database
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  path: ^1.9.0

  # Navigation
  go_router: ^14.0.0

  # Audio
  just_audio: ^0.9.36
  audio_session: ^0.1.18

  # UI
  cached_network_image: ^3.3.0
  flutter_animate: ^4.5.0
  google_fonts: ^6.2.0
  shimmer: ^3.0.0
  flutter_svg: ^2.0.0

  # Storage
  shared_preferences: ^2.2.0

  # Utils
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  injectable_generator: ^2.4.0
  build_runner: ^2.4.0
  bloc_test: ^9.1.0
  mocktail: ^1.0.0

flutter:
  assets:
    - assets/databases/learn_db.db
  fonts:
    - family: BeVietnamPro
      fonts:
        - asset: assets/fonts/BeVietnamPro-Regular.ttf
        - asset: assets/fonts/BeVietnamPro-Medium.ttf
          weight: 500
        - asset: assets/fonts/BeVietnamPro-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/BeVietnamPro-Bold.ttf
          weight: 700
```

### 4.2 UseCase Convention

We don't use a base `UseCase<Type, Params>` class. Every use-case is a concrete
`@injectable` class with an `execute(...)` method that returns
`Either<AppException, T>`. Repositories and data sources throw raw exceptions;
the use-case is the single boundary that wraps them into `AppException`.

```dart
// lib/features/<feature>/domain/usecases/<verb>_<noun>.dart

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/domain/base/cancel_token.dart';
import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../model/<entity>.dart';
import '../repository/<feature>_repository.dart';

@injectable
class GetSomethingUseCase {
  final SomethingRepository _repository;

  GetSomethingUseCase(this._repository);

  Future<Either<AppException, SomethingEntity?>> execute({
    required int id,
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _repository.getSomething(
        id: id,
        cancelToken: cancelToken,
      );
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
```

Rules:

- Class name ends in `UseCase` (or feature-domain verb like `GetX` / `CheckX`).
- Annotate `@injectable` so it's picked up by the generator.
- Private repository field, single positional constructor arg: `MyUseCase(this._repository)`.
- Method is `execute({...})` (never `call`) — named params keep call sites readable.
- Accept an optional `CancellationToken? cancelToken` whenever the underlying repo call may be cancelled.
- Return `Future<Either<AppException, T>>` (or `T?`); never return raw values or throw.
- `try/catch` once at the end: rethrow `AppException`s untouched, wrap anything else as `AppUncaughtException(e)`.

### 4.3 Errors

We reuse the existing app-wide error hierarchy. **Do not create per-layer
Failure / Exception classes.**

| Class | Where | Purpose |
|---|---|---|
| `AppException` | `lib/base/errors/base/app_exception.dart` | Sealed base; has `AppExceptionType` enum (`remote`, `parse`, `uncaught`, `validation`, `payment`). |
| `AppUncaughtException` | `lib/base/errors/uncaught/app_uncaught_exception.dart` | Wraps any non-`AppException` thrown inside a use-case. |
| `AppExceptionWrapper` | `lib/base/errors/base/app_exception_wrapper.dart` | For propagating extra metadata to the UI. |
| `CancellationToken` | `lib/base/domain/base/cancel_token.dart` | Cancellation contract passed through repo → data-source. |

### 4.4 BLoC / Cubit Convention

Same rules as use-cases — `@injectable`, positional ctor args, private fields:

```dart
@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStats _getStats;

  DashboardBloc(this._getStats) : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
  }

  Future<void> _onLoad(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    final result = await _getStats.execute();
    result.fold(
      (exception) => emit(DashboardError(message: exception.toString())),
      (stats) => emit(DashboardLoaded(stats: stats)),
    );
  }
}
```

Resolve in the widget tree from the shared `getIt`:

```dart
BlocProvider(create: (_) => getIt<DashboardBloc>()..add(const LoadDashboard()))
```

### 4.5 Dependency Injection (injectable + code-gen)

**No manual `GetIt` registrations.** All DI goes through `injectable` annotations
which are compiled into `lib/di/di.config.dart` by `build_runner`. The single
shared service locator is `getIt` from `lib/di/di.dart`.

```dart
// lib/di/di.dart

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'di.config.dart';

final GetIt getIt = GetIt.instance;

@injectableInit
void configureInjection() => getIt.init();
```

External services (anything you can't annotate — SDK types, async constructors)
go in a `@module`:

```dart
// lib/di/modules.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:learn_english_app/core/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

@module
abstract class ServiceModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  FlutterSecureStorage get flutterSecureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @singleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}

@module
abstract class DatabaseModule {
  @preResolve
  @singleton
  Future<Database> get database => DatabaseHelper.initDatabase();
}
```

Annotation cheatsheet:

| Layer | Annotation | Why |
|---|---|---|
| DataSource impl | `@LazySingleton(as: XLocalDataSource)` | One instance, lazy creation, registers as abstract type. |
| Repository impl | `@LazySingleton(as: XRepository)` | Same — bound to the abstract contract. |
| UseCase | `@injectable` (factory) | Cheap to construct, no shared state. |
| Bloc / Cubit | `@injectable` (factory) | Fresh instance per screen. |
| Core utility (e.g. `AudioManager`) | `@lazySingleton` | One shared instance for the whole app. |
| Pre-resolved async (`SharedPreferences`, `Database`) | `@preResolve` inside a `@module` | Awaited before `getIt` is ready. |

Worked example for one feature — wire up by **annotating**, not registering:

```dart
@LazySingleton(as: PhoneticLocalDataSource)
class PhoneticLocalDataSourceImpl implements PhoneticLocalDataSource {
  final Database _database;
  PhoneticLocalDataSourceImpl(this._database);
}

@LazySingleton(as: PhoneticRepository)
class PhoneticRepositoryImpl implements PhoneticRepository {
  final PhoneticLocalDataSource _localDataSource;
  PhoneticRepositoryImpl(this._localDataSource);
}

@injectable
class GetPhoneticCategories {
  final PhoneticRepository _repository;
  GetPhoneticCategories(this._repository);
  Future<Either<AppException, List<PhoneticCategory>>> execute() async { ... }
}

@injectable
class PhoneticCategoriesBloc extends Bloc<...> {
  final GetPhoneticCategories _getCategories;
  PhoneticCategoriesBloc(this._getCategories) : super(...);
}
```

After adding or changing any `@injectable` / `@module` / `@LazySingleton`, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4.6 main.dart

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(...);
  await AppDiConfig.getInstance().init(); // calls configureInjection() → getIt.init()
  runApp(const MyApp());
}
```

### 4.7 MyApp

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bayan English',
      debugShowCheckedModeBanner: false,
      theme: BayanTheme.light(),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: AppRouter.router,
    );
  }
}
```

---

## 5. Design System - Bayan Blue

### 5.1 Colors

```dart
// lib/core/theme/bayan_colors.dart

abstract class BayanColors {
  // Primary
  static const primary       = Color(0xFF3B82F6);
  static const primaryLight  = Color(0xFF93C5FD);
  static const primaryDark   = Color(0xFF1D4ED8);

  // Surface
  static const surface       = Color(0xFFF8F9FF);
  static const surfaceCard   = Color(0xFFFFFFFF);
  static const background    = Color(0xFFF1F5F9);

  // Text
  static const textPrimary   = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const success       = Color(0xFF22C55E);
  static const warning       = Color(0xFFF59E0B);
  static const error         = Color(0xFFEF4444);

  // Level Colors
  static const a1Color = Color(0xFF22C55E);
  static const a2Color = Color(0xFF3B82F6);
  static const b1Color = Color(0xFFF59E0B);
  static const b2Color = Color(0xFFEF4444);
  static const c1Color = Color(0xFF8B5CF6);
  static const c2Color = Color(0xFFEC4899);
}
```

### 5.2 Typography

```dart
// lib/core/theme/bayan_typography.dart

abstract class BayanTypography {
  static const _fontFamily = 'BeVietnamPro';

  static const headlineLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.w700, height: 1.3,
  );
  static const headlineMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 22, fontWeight: FontWeight.w600, height: 1.3,
  );
  static const titleLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w600, height: 1.4,
  );
  static const bodyLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
  );
  static const bodyMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
  );
  static const labelLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4,
  );
  static const caption = TextStyle(
    fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w400, height: 1.4,
    color: Color(0xFF64748B),
  );
}
```

### 5.3 Theme

```dart
// lib/core/theme/bayan_theme.dart

class BayanTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    fontFamily: 'BeVietnamPro',
    colorScheme: ColorScheme.fromSeed(
      seedColor: BayanColors.primary,
      surface: BayanColors.surface,
    ),
    scaffoldBackgroundColor: BayanColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: BayanTypography.titleLarge,
    ),
    cardTheme: CardTheme(
      color: BayanColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BayanColors.primary,
        foregroundColor: BayanColors.textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: BayanTypography.labelLarge,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: BayanColors.primary,
      unselectedItemColor: BayanColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
```

### 5.4 Component Specs

| Component | Radius | Elevation | Padding |
|---|---|---|---|
| Cards | 16px | 0 (BoxShadow) | 16px |
| Buttons | 8px | 0 | 14v / 24h |
| Chips | 20px (pill) | 0 | 6v / 12h |
| Bottom Nav | 0 | 8 | - |
| Bottom Sheet | 24px top | 4 | 24px |
| Input Fields | 12px | 0 | 16px |

---

## 6. Core Layer

### 6.1 Database Helper

```dart
// lib/core/database/database_helper.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> initDatabase() async {
    if (_database != null) return _database!;

    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDir.path, 'learn_db.db');

    // Copy from assets on first launch
    if (!await File(dbPath).exists()) {
      final data = await rootBundle.load('assets/databases/learn_db.db');
      final bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    _database = await openDatabase(dbPath, readOnly: false);
    return _database!;
  }

  static Future<Database> get database async {
    return _database ?? await initDatabase();
  }
}
```

### 6.2 Audio Manager

`@lazySingleton` — one shared player for the whole app, injected anywhere via
`getIt<AudioManager>()`.

```dart
// lib/core/utils/audio_manager.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AudioManager {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Stream<Duration> get positionStream     => _player.onPositionChanged;
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;
  Stream<Duration> get durationStream     => _player.onDurationChanged;
  Stream<void> get completionStream       => _player.onPlayerComplete;

  Future<void> play(String url) async {
    await _player.stop();
    await _player.play(UrlSource(url));
  }

  Future<void> playFromPosition(String url, Duration position) async {
    await _player.stop();
    await _player.play(UrlSource(url), position: position);
  }

  Future<void> pause()  => _player.pause();
  Future<void> resume() => _player.resume();
  Future<void> stop()   => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);

  @disposeMethod
  Future<void> close() => _player.dispose();
}
```

---

## 7. Database Schema & ER Map

### 7.1 Complete Entity-Relationship

```
learning_level (6 levels: A1-C2)
│
├── level_phonetic_topic ──► phonetic (4 categories)
│                                └── phoneticTopic (115 topics)
│                                     └── phonetic_section (967 sections)
│                                          ├── phonetic_data_item (206)
│                                          ├── phonetic_example (1,815)
│                                          └── phonetic_table_item (283)
│
├── level_grammar_topic ──► grammar_topics (20 topics)
│   level_grammar_subtopic     └── grammar_sub_topics (114 subtopics)
│                                   └── grammar_content (114)
│                                        └── grammar_rule (1,159 rules)
│                                             ├── grammar_rule_description (1,115)
│                                             │   └── grammar_rule_example (2,284)
│                                             └── grammar_rule_test (646 tests)
│                                   grammar_test (20 topic-level tests)
│
├── level_vocabulary_topic ──► vocaTopic (14 topics)
│   level_vocabulary_subtopic    └── vocaSubTopic (101 subtopics)
│                                     └── vocabulary (2,514 words)
│
├── level_sentence_topic ──► sentenceTopic (20 topics)
│   level_sentence_subtopic    └── sentencesSubTopic (100 subtopics)
│                                   └── sentencesContent (2,089 sentences)
│
├── level_conversation_block ──► conversation_level (14 blocks)
│   level_conversation_lesson      └── conversation_lesson (138 lessons)
│                                       └── conversation_sentence (2,932 lines)
│
├── word_list_topic (6 level lists) → word_list (5,586 words)
└── my_word_list (user-saved, starts empty)

audio_files (59,744 total | 4 voices: us_male, us_female, uk_male, uk_female)
```

### 7.2 Content Statistics

| Module | Topics | Items | Audio |
|---|---|---|---|
| Phonetics | 4 categories / 115 topics | 967 sections / 1,815 examples | 7,260 |
| Grammar | 20 topics / 114 subtopics | 1,159 rules / 646 tests | - |
| Vocabulary | 14 topics / 101 subtopics | 2,514 words | 10,056 |
| Sentences | 20 topics / 100 subtopics | 2,089 sentences | 8,356 |
| Conversations | 14 blocks / 138 lessons | 2,932 dialogue lines | 11,728 |
| Word List | 6 level lists | 5,586 words | 22,344 |
| **Total** | | | **59,744** |

---

## 8. CDN & Asset Management

Replace `YOUR_DOMAIN` with your CloudFront distribution domain:

```bash
aws cloudfront get-distribution --id E1ABCDEF234XYZ \
  --query "Distribution.DomainName" --output text
```

```dart
// lib/core/network/cdn_config.dart

abstract class CdnConfig {
  static const baseUrl = 'https://YOUR_DOMAIN.cloudfront.net';

  // ══════════════════════════════════════════════
  //  AUDIO URLs (59,744 files)
  //  Pattern: {baseUrl}/audio/{voice}/{source}/{id}.mp3
  //  Voices: us_male, us_female, uk_male, uk_female
  // ══════════════════════════════════════════════

  // Vocabulary audio (2,514 words × 4 voices = 10,056)
  // DB: audio_files WHERE source_table = 'vocabulary'
  static String vocabularyAudio(int id, String voice) =>
      '$baseUrl/audio/$voice/vocabulary/$id.mp3';

  // Word List audio (5,586 words × 4 voices = 22,344)
  // DB: audio_files WHERE source_table = 'word_list'
  static String wordListAudio(int id, String voice) =>
      '$baseUrl/audio/$voice/word_list/$id.mp3';

  // Sentences audio (2,089 sentences × 4 voices = 8,356)
  // DB: audio_files WHERE source_table = 'sentencesContent'
  static String sentenceAudio(int id, String voice) =>
      '$baseUrl/audio/$voice/sentences/$id.mp3';

  // Phonetic Example audio (1,815 examples × 4 voices = 7,260)
  // DB: audio_files WHERE source_table = 'phonetic_example'
  static String phoneticExampleAudio(int id, String voice) =>
      '$baseUrl/audio/$voice/phonetic_example/$id.mp3';

  // Conversation audio (2,932 sentences × 4 voices = 11,728)
  // DB: audio_files WHERE source_table = 'conversation_sentence'
  static String conversationAudio(int id, String voice) =>
      '$baseUrl/audio/$voice/conversation/$id.mp3';

  // ══════════════════════════════════════════════
  //  IMAGE URLs
  // ══════════════════════════════════════════════

  // Vocabulary word images (~2,635 files, .webp)
  // DB: vocabulary.imageResourceId → e.g. "boy"
  static String wordImage(String imageResourceId) =>
      '$baseUrl/word_img/$imageResourceId.webp';

  // Grammar diagram images (~231 files, .webp)
  // DB: grammar_rule.image → e.g. "a01_01_01"
  static String grammarImage(String imageName) =>
      '$baseUrl/grammarImg/$imageName.webp';

  // Phonetic Alphabet images (26 files, .png)
  // DB: phoneticTopic.icon → e.g. "the_letter_a"
  static String phoneticAlphabetImage(String icon) =>
      '$baseUrl/phonetic/alphabet/$icon.png';

  // Phonetic Consonants/Vowels images (78 files, .png)
  // e.g. "consonants_b", "consonants_ch"
  static String phoneticSoundImage(String name) =>
      '$baseUrl/phonetic/img/$name.png';

  // Phonetic Multigraph images (62 files, .png)
  // e.g. "multigraphs_ch-min"
  static String phoneticMultigraphImage(String name) =>
      '$baseUrl/phonetic/multigraphs/$name.png';

  // ══════════════════════════════════════════════
  //  GENERIC HELPER (from audio_files.file_path)
  // ══════════════════════════════════════════════

  // Use directly with audio_files.file_path column
  // DB value: "us_male/vocabulary/1.mp3"
  static String audioFromPath(String filePath) =>
      '$baseUrl/audio/$filePath';
}
```

### 8.1 Quick reference

| Asset | DB source | URL pattern | Ext | Count |
|---|---|---|---|---|
| Vocabulary audio | `audio_files.source_table = 'vocabulary'` | `/audio/{voice}/vocabulary/{id}.mp3` | `.mp3` | 10,056 |
| Word-list audio | `audio_files.source_table = 'word_list'` | `/audio/{voice}/word_list/{id}.mp3` | `.mp3` | 22,344 |
| Sentence audio | `audio_files.source_table = 'sentencesContent'` | `/audio/{voice}/sentences/{id}.mp3` | `.mp3` | 8,356 |
| Phonetic audio | `audio_files.source_table = 'phonetic_example'` | `/audio/{voice}/phonetic_example/{id}.mp3` | `.mp3` | 7,260 |
| Conversation audio | `audio_files.source_table = 'conversation_sentence'` | `/audio/{voice}/conversation/{id}.mp3` | `.mp3` | 11,728 |
| Word images | `vocabulary.imageResourceId` | `/word_img/{name}.webp` | `.webp` | ~2,635 |
| Grammar images | `grammar_rule.image` | `/grammarImg/{name}.webp` | `.webp` | ~231 |
| Phonetic alphabet | `phoneticTopic.icon` | `/phonetic/alphabet/{icon}.png` | `.png` | 26 |
| Phonetic sounds | by name | `/phonetic/img/{name}.png` | `.png` | 78 |
| Phonetic multigraphs | by name | `/phonetic/multigraphs/{name}.png` | `.png` | 62 |

### 8.2 Voices

| Key | Label |
|---|---|
| `us_male`   | US Male |
| `us_female` | US Female |
| `uk_male`   | UK Male |
| `uk_female` | UK Female |

### 8.3 S3 bucket structure

```
audio/
├── us_male/    (vocabulary/ word_list/ sentences/ phonetic_example/ conversation/)
├── us_female/
├── uk_male/
└── uk_female/
word_img/                    (~2,635 .webp)
grammarImg/                  (~231 .webp)
phonetic/
├── alphabet/                (26 .png)
├── img/                     (78 .png — consonants/vowels)
└── multigraphs/             (62 .png)
```

---

## 9. Feature: Phonetics

Full clean-architecture vertical slice — built on Phase 1 (core) + Phase 2 (DI
conventions). Sources from local SQLite, audio streams from CloudFront.

**Schema** (corrected from the original spec):

| Table | Rows | Key columns |
|---|---|---|
| `phonetic` | 4 | `id, title, title_ar, icon, articles` |
| `phoneticTopic` | 115 | `id, subId, title, title_ar, phoneTitle, word, icon` |
| `phonetic_section` | 967 | `id, topic_id, accent, sort_order, type, super_type, title, title_ar, body, body_ar` |
| `phonetic_example` | 1,815 | `id, section_id, sort_order, word, word_ar, phonetic` |
| `phonetic_data_item` | 206 | `id, section_id, sort_order, text_en, text_ar` |
| `phonetic_table_item` | 283 | `id, section_id, sort_order, title, value` |
| `level_phonetic_topic` | 115 | `phoneticId, levelId, id` — `phoneticId` is the **topic id**, not category id |

**Section `type`**: `title`, `subTitle`, `table`, `content`, `tip`
  (the original spec used `data` / `example` — wrong; examples and data items
  are children of `content` sections).

**Accents**: `'us'` and `'uk'` (short keys; map to `us_male` / `uk_male` voices
when building CDN audio URLs).

### 9.1 Domain Layer

```dart
// lib/features/phonetics/domain/entities/phonetic_section.dart

class PhoneticSection extends Equatable {
  final int id;
  final int topicId;
  final String accent;           // 'us' | 'uk'
  final int sortOrder;
  final String type;             // 'title' | 'subTitle' | 'table' | 'content' | 'tip'
  final String? superType;       // 'section' | 'accent' | 'tip' | 'warning' | 'sectionWithImage' | 'sound'
  final String? title;
  final String? titleAr;
  final String? body;
  final String? bodyAr;

  // Hydrated by the repository based on `type`:
  final List<PhoneticTableItem> tableItems;   // type=='table'
  final List<PhoneticDataItem> dataItems;     // type=='content'
  final List<PhoneticExample> examples;       // type=='content'

  const PhoneticSection({ ... });
}
```

The remaining entities (`PhoneticCategory`, `PhoneticTopic`, `PhoneticExample`,
`PhoneticDataItem`, `PhoneticTableItem`) are flat `Equatable` value objects —
one field per DB column.

**Repository contract** — returns raw `T` (not `Either`); exceptions bubble:

```dart
abstract class PhoneticRepository {
  Future<List<PhoneticCategory>> getCategories();
  Future<List<PhoneticTopic>> getTopicsByCategory(int categoryId);
  Future<List<PhoneticTopic>> getTopicsForLevel(int levelId);
  Future<List<PhoneticSection>> getSections({
    required int topicId,
    required String accent,
  });
}
```

**Use-cases** — all `@injectable`, `execute()`, `Either<AppException, T>`:

```dart
@injectable
class GetPhoneticSections {
  final PhoneticRepository _repository;
  GetPhoneticSections(this._repository);

  Future<Either<AppException, List<PhoneticSection>>> execute({
    required int topicId,
    required String accent,
  }) async {
    try {
      final result = await _repository.getSections(
        topicId: topicId,
        accent: accent,
      );
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
```

`GetPhoneticCategories.execute()` and `GetPhoneticTopics.execute({categoryId})`
follow the same template.

### 9.2 Data Layer

Every model extends its entity and adds a `fromMap` factory.
DataSource + Repository are both annotated for code-gen DI:

```dart
@LazySingleton(as: PhoneticLocalDataSource)
class PhoneticLocalDataSourceImpl implements PhoneticLocalDataSource {
  final Database _database;
  PhoneticLocalDataSourceImpl(this._database);

  @override
  Future<List<PhoneticTopicModel>> getTopicsForLevel(int levelId) async {
    // NOTE: level_phonetic_topic.phoneticId is the TOPIC id, not category id.
    final result = await _database.rawQuery('''
      SELECT pt.* FROM phoneticTopic pt
      INNER JOIN level_phonetic_topic lpt ON pt.id = lpt.phoneticId
      WHERE lpt.levelId = ?
      ORDER BY pt.id ASC
    ''', [levelId]);
    return result.map(PhoneticTopicModel.fromMap).toList();
  }
  // ...
}
```

**Repository hydrates children based on `type`** — `'table'` sections load
`phonetic_table_item`, `'content'` sections load both examples and data items in
parallel:

```dart
@LazySingleton(as: PhoneticRepository)
class PhoneticRepositoryImpl implements PhoneticRepository {
  final PhoneticLocalDataSource _localDataSource;
  PhoneticRepositoryImpl(this._localDataSource);

  @override
  Future<List<PhoneticSection>> getSections({
    required int topicId,
    required String accent,
  }) async {
    final sections = await _localDataSource.getSections(topicId, accent);
    return Future.wait(sections.map(_hydrateChildren));
  }

  Future<PhoneticSectionModel> _hydrateChildren(PhoneticSectionModel s) async {
    switch (s.type) {
      case 'table':
        final items = await _localDataSource.getTableItems(s.id);
        return s.copyWithChildren(tableItems: items);
      case 'content':
        final examplesFut  = _localDataSource.getExamples(s.id);
        final dataItemsFut = _localDataSource.getDataItems(s.id);
        return s.copyWithChildren(
          examples:  await examplesFut,
          dataItems: await dataItemsFut,
        );
      default:
        return s;
    }
  }
}
```

### 9.3 Presentation Layer

Three blocs, all `@injectable`:

| Bloc | Loads | Drives |
|---|---|---|
| `PhoneticCategoriesBloc` | `GetPhoneticCategories.execute()` | `PhoneticsCategoriesScreen` (grid) |
| `PhoneticTopicsBloc`     | `GetPhoneticTopics.execute(categoryId:)` | `PhoneticsTopicsScreen` (list) |
| `PhoneticDetailBloc`     | `GetPhoneticSections.execute(topicId:, accent:)` | `PhoneticsDetailScreen` (accent toggle + sections) |

`PhoneticDetailBloc` also owns the audio lifecycle:

```dart
@injectable
class PhoneticDetailBloc extends Bloc<PhoneticDetailEvent, PhoneticDetailState> {
  final GetPhoneticSections _getSections;
  final AudioManager _audioManager;

  int? _currentTopicId;
  StreamSubscription<void>? _playerCompleteSub;

  PhoneticDetailBloc(this._getSections, this._audioManager)
      : super(const PhoneticDetailInitial()) {
    on<LoadPhoneticDetail>(_onLoad);
    on<ChangeAccent>(_onChangeAccent);     // stops audio, re-fetches
    on<PlayExampleAudio>(_onPlayAudio);    // marks playingExampleId + plays URL
    on<StopExampleAudio>(_onStopAudio);    // clears playingExampleId

    // Auto-clear the playing indicator when the player completes.
    _playerCompleteSub =
        _audioManager.completionStream.listen((_) => add(const StopExampleAudio()));
  }

  Future<void> _onPlayAudio(PlayExampleAudio e, Emitter emit) async {
    final s = state;
    if (s is! PhoneticDetailLoaded) return;
    emit(s.copyWith(playingExampleId: e.exampleId));

    final voiceKey = s.currentAccent == 'uk'
        ? AppConstants.voiceUkMale
        : AppConstants.voiceUsMale;
    await _audioManager.play(CdnConfig.phoneticExampleAudio(e.exampleId, voiceKey));
  }

  @override
  Future<void> close() async {
    await _playerCompleteSub?.cancel();
    await _audioManager.stop();
    return super.close();
  }
}
```

**Rendering** — `PhoneticSectionWidget` dispatches on `section.type`:

| `type` | Widget |
|---|---|
| `title` | large heading + body |
| `subTitle` | small heading + body |
| `table` | `IpaTableWidget` (key/value rows) |
| `tip` | tinted card; warning vs. tip determined by `superType` |
| `content` | optional heading/body, `dataItems` as bullet list, `examples` as `PhoneticExampleTile` (tap to play) |

**Routes** — nested `GoRoute` with path params:

```
/phonetics                        → PhoneticsCategoriesScreen
/phonetics/:catId                 → PhoneticsTopicsScreen
/phonetics/:catId/:topicId        → PhoneticsDetailScreen
```

Helpers on `AppRoutes`:

```dart
static String phoneticsTopics(int catId)       => '/phonetics/$catId';
static String phoneticsDetail(int catId, int topicId)
    => '/phonetics/$catId/$topicId';
```

Resolved at the screen via `getIt<...>`:

```dart
BlocProvider(
  create: (_) => getIt<PhoneticDetailBloc>()
    ..add(LoadPhoneticDetail(topicId: topicId, accent: 'us')),
  child: ...,
)
```

## 10. Feature: Grammar

### 10.1 Domain

```dart
// ─── Entities ───

class GrammarTopic extends Equatable {
  final int id;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  // ...
}

class GrammarSubtopic extends Equatable {
  final int id;
  final int topicId;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  // ...
}

class GrammarRule extends Equatable {
  final int id;
  final int contentId;
  final int sortOrder;
  final String title;
  final String? image;
  final List<GrammarRuleDescription> descriptions;
  // ...
}

class GrammarRuleDescription extends Equatable {
  final int id;
  final int ruleId;
  final String textEn;
  final String textAr;
  final String? mustEn;
  final String? image;
  final List<GrammarRuleExample> examples;
  // ...
}

class GrammarRuleExample extends Equatable {
  final int id;
  final int descriptionId;
  final String textEn;
  final String textAr;
  final String? mustEn;
  // ...
}

class GrammarTest extends Equatable {
  final int id;
  final int ruleId;
  final String question;
  final String questionAr;
  final String correctAnswer;
  final List<String> options;
  // ...
}
```

```dart
// ─── Repository ───

abstract class GrammarRepository {
  Future<Either<Failure, List<GrammarTopic>>> getTopicsForLevel(int levelId);
  Future<Either<Failure, List<GrammarSubtopic>>> getSubtopics(int topicId);
  Future<Either<Failure, List<GrammarRule>>> getLesson(int subtopicId);
  Future<Either<Failure, List<GrammarTest>>> getTests(int contentId);
}
```

```dart
// ─── UseCases ───

class GetGrammarTopics extends UseCase<List<GrammarTopic>, LevelParams> { ... }
class GetGrammarSubtopics extends UseCase<List<GrammarSubtopic>, TopicParams> { ... }
class GetGrammarLesson extends UseCase<List<GrammarRule>, SubtopicParams> { ... }
class GetGrammarTest extends UseCase<List<GrammarTest>, ContentParams> { ... }
```

### 10.2 Data

```dart
// ─── DataSource ───

abstract class GrammarLocalDataSource {
  Future<List<GrammarTopicModel>> getTopicsForLevel(int levelId);
  Future<List<GrammarSubtopicModel>> getSubtopics(int topicId);
  Future<List<GrammarRuleModel>> getRules(int contentId);
  Future<List<GrammarRuleDescriptionModel>> getDescriptions(int ruleId);
  Future<List<GrammarRuleExampleModel>> getExamples(int descriptionId);
  Future<List<GrammarTestModel>> getTests(int contentId);
}

class GrammarLocalDataSourceImpl implements GrammarLocalDataSource {
  final Database database;

  GrammarLocalDataSourceImpl({required this.database});

  @override
  Future<List<GrammarTopicModel>> getTopicsForLevel(int levelId) async {
    final result = await database.rawQuery('''
      SELECT gt.* FROM grammar_topics gt
      INNER JOIN level_grammar_topic lgt ON gt.id = lgt.topicId
      WHERE lgt.levelId = ?
    ''', [levelId]);
    return result.map((m) => GrammarTopicModel.fromMap(m)).toList();
  }

  @override
  Future<List<GrammarSubtopicModel>> getSubtopics(int topicId) async {
    final result = await database.query(
      'grammar_sub_topics',
      where: 'topicId = ?',
      whereArgs: [topicId],
    );
    return result.map((m) => GrammarSubtopicModel.fromMap(m)).toList();
  }

  // ... other methods follow same pattern
}
```

```dart
// ─── Repository Implementation ───

class GrammarRepositoryImpl implements GrammarRepository {
  final GrammarLocalDataSource localDataSource;

  GrammarRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<GrammarRule>>> getLesson(int subtopicId) async {
    try {
      final rules = await localDataSource.getRules(subtopicId);
      final enrichedRules = <GrammarRule>[];

      for (final rule in rules) {
        final descriptions = await localDataSource.getDescriptions(rule.id);
        final enrichedDescs = <GrammarRuleDescription>[];

        for (final desc in descriptions) {
          final examples = await localDataSource.getExamples(desc.id);
          enrichedDescs.add(desc.copyWith(examples: examples));
        }

        enrichedRules.add(rule.copyWith(descriptions: enrichedDescs));
      }

      return Right(enrichedRules);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  // ... other methods follow same pattern
}
```

### 10.3 Presentation

```dart
// ─── BLoC ───

// Events
abstract class GrammarLessonEvent extends Equatable { ... }
class LoadGrammarLesson extends GrammarLessonEvent {
  final int subtopicId;
  LoadGrammarLesson({required this.subtopicId});
}

// States
abstract class GrammarLessonState extends Equatable { ... }
class GrammarLessonInitial extends GrammarLessonState {}
class GrammarLessonLoading extends GrammarLessonState {}
class GrammarLessonLoaded extends GrammarLessonState {
  final List<GrammarRule> rules;
  final GrammarSubtopic subtopic;
  GrammarLessonLoaded({required this.rules, required this.subtopic});
}
class GrammarLessonError extends GrammarLessonState {
  final String message;
  GrammarLessonError({required this.message});
}

// Bloc
class GrammarLessonBloc extends Bloc<GrammarLessonEvent, GrammarLessonState> {
  final GetGrammarLesson getLesson;

  GrammarLessonBloc({required this.getLesson}) : super(GrammarLessonInitial()) {
    on<LoadGrammarLesson>((event, emit) async {
      emit(GrammarLessonLoading());
      final result = await getLesson(SubtopicParams(subtopicId: event.subtopicId));
      result.fold(
        (failure) => emit(GrammarLessonError(message: failure.message)),
        (rules) => emit(GrammarLessonLoaded(rules: rules, subtopic: /* ... */)),
      );
    });
  }
}
```

```dart
// ─── Screen ───

class GrammarLessonScreen extends StatelessWidget {
  final int subtopicId;

  const GrammarLessonScreen({super.key, required this.subtopicId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GrammarLessonBloc>()
        ..add(LoadGrammarLesson(subtopicId: subtopicId)),
      child: Scaffold(
        body: BlocBuilder<GrammarLessonBloc, GrammarLessonState>(
          builder: (context, state) {
            return switch (state) {
              GrammarLessonLoading() => const LoadingShimmer(),
              GrammarLessonError(:final message) => ErrorDisplay(message: message),
              GrammarLessonLoaded(:final rules) => ListView.builder(
                itemCount: rules.length,
                itemBuilder: (_, i) => RuleCard(rule: rules[i]),
              ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}
```

---

## 11. Feature: Vocabulary

### 11.1 Domain

```dart
// ─── Entities ───

class VocaTopic extends Equatable {
  final int topicId;
  final String imageResourceId;
  final String nameAr;
  final String name;
  final String cover;
  final String icon;
  final int subTopicCount;
  // ...
}

class VocaSubtopic extends Equatable {
  final int id;
  final int topicId;
  final String imageResourceId;
  final String nameAr;
  final String name;
  // ...
}

class VocabularyWord extends Equatable {
  final int id;
  final int subTopicId;
  final String nameAr;
  final String name;
  final String description;
  final String imageResourceId;
  final String sound;
  final String transcription;
  final String usage;
  // ...
}
```

```dart
// ─── Repository ───

abstract class VocabularyRepository {
  Future<Either<Failure, List<VocaTopic>>> getTopicsForLevel(int levelId);
  Future<Either<Failure, List<VocaSubtopic>>> getSubtopics(int topicId);
  Future<Either<Failure, List<VocabularyWord>>> getWords(int subtopicId);
  Future<Either<Failure, List<VocabularyWord>>> searchWords(String query);
  Future<Either<Failure, void>> addToMyWords(VocabularyWord word);
}
```

```dart
// ─── UseCases ───

class GetVocabularyTopics extends UseCase<List<VocaTopic>, LevelParams> { ... }
class GetVocabularySubtopics extends UseCase<List<VocaSubtopic>, TopicParams> { ... }
class GetVocabularyWords extends UseCase<List<VocabularyWord>, SubtopicParams> { ... }
class SearchVocabulary extends UseCase<List<VocabularyWord>, SearchParams> { ... }
class ToggleFavoriteWord extends UseCase<void, VocabularyWord> { ... }
```

### 11.2 Data

```dart
// ─── DataSource ───

class VocabularyLocalDataSourceImpl implements VocabularyLocalDataSource {
  final Database database;

  VocabularyLocalDataSourceImpl({required this.database});

  @override
  Future<List<VocabularyWordModel>> getWords(int subtopicId) async {
    final result = await database.query(
      'vocabulary',
      where: 'subTopicId = ?',
      whereArgs: [subtopicId],
    );
    return result.map((m) => VocabularyWordModel.fromMap(m)).toList();
  }

  @override
  Future<List<VocabularyWordModel>> searchWords(String query) async {
    final result = await database.query(
      'vocabulary',
      where: 'name LIKE ? OR ita LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      limit: 50,
    );
    return result.map((m) => VocabularyWordModel.fromMap(m)).toList();
  }

  @override
  Future<void> addToMyWords(VocabularyWordModel word) async {
    await database.insert('my_word_list', {
      'word': word.name,
      'word_ar': word.nameAr,
      'pronunciation': word.transcription,
      'example': word.usage,
    });
  }
}
```

### 11.3 Presentation

```dart
// ─── BLoC ───

// Events
abstract class VocabularyWordsEvent extends Equatable { ... }
class LoadWords extends VocabularyWordsEvent { final int subtopicId; ... }
class SearchWords extends VocabularyWordsEvent { final String query; ... }
class PlayWordAudio extends VocabularyWordsEvent { final int wordId; final String voice; ... }
class ToggleFavorite extends VocabularyWordsEvent { final VocabularyWord word; ... }

// States
class VocabularyWordsLoaded extends VocabularyWordsState {
  final List<VocabularyWord> words;
  final int? playingWordId;
  ...
}

// Bloc
class VocabularyWordsBloc extends Bloc<VocabularyWordsEvent, VocabularyWordsState> {
  final GetVocabularyWords getWords;
  final SearchVocabulary searchVocabulary;
  final ToggleFavoriteWord toggleFavorite;
  final AudioManager audioManager;

  VocabularyWordsBloc({ ... }) : super(VocabularyWordsInitial()) {
    on<LoadWords>((event, emit) async {
      emit(VocabularyWordsLoading());
      final result = await getWords(SubtopicParams(subtopicId: event.subtopicId));
      result.fold(
        (f) => emit(VocabularyWordsError(message: f.message)),
        (words) => emit(VocabularyWordsLoaded(words: words)),
      );
    });

    on<PlayWordAudio>((event, emit) async {
      final url = CdnConfig.vocabularyAudio(event.wordId, event.voice);
      await audioManager.play(url);
    });

    on<ToggleFavorite>((event, emit) async {
      await toggleFavorite(event.word);
    });
  }
}
```

```dart
// ─── Screen ───

class WordDetailScreen extends StatelessWidget {
  final VocabularyWord word;

  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BayanAppBar(title: word.name),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Word Image from CDN
            CachedNetworkImage(
              imageUrl: CdnConfig.wordImageUrl(word.imageResourceId),
              height: 200,
              placeholder: (_, __) => const LoadingShimmer(),
            ),
            const SizedBox(height: 16),

            // Word + Arabic + Phonetic
            Text(word.name, style: BayanTypography.headlineLarge),
            Text(word.nameAr, style: BayanTypography.titleLarge),
            Text(word.transcription, style: BayanTypography.bodyMedium),
            const SizedBox(height: 16),

            // 4 Voice Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AudioPlayButton(
                  label: 'US Male',
                  onTap: () => context.read<VocabularyWordsBloc>()
                    .add(PlayWordAudio(wordId: word.id, voice: 'us_male')),
                ),
                AudioPlayButton(
                  label: 'US Female',
                  onTap: () => context.read<VocabularyWordsBloc>()
                    .add(PlayWordAudio(wordId: word.id, voice: 'us_female')),
                ),
                AudioPlayButton(
                  label: 'UK Male',
                  onTap: () => context.read<VocabularyWordsBloc>()
                    .add(PlayWordAudio(wordId: word.id, voice: 'uk_male')),
                ),
                AudioPlayButton(
                  label: 'UK Female',
                  onTap: () => context.read<VocabularyWordsBloc>()
                    .add(PlayWordAudio(wordId: word.id, voice: 'uk_female')),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description + Usage
            Text(word.description, style: BayanTypography.bodyLarge),
            const SizedBox(height: 8),
            Text('"${word.usage}"', style: BayanTypography.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
            )),
            const SizedBox(height: 24),

            // Add to My Words
            BayanButton(
              label: 'Add to My Words',
              icon: Icons.star_border,
              onTap: () => context.read<VocabularyWordsBloc>()
                .add(ToggleFavorite(word: word)),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 12. Feature: Sentences

### 12.1 Domain

```dart
// ─── Entities ───

class SentenceTopic extends Equatable {
  final int topicId;
  final String titleEn;
  final String titleAr;
  final int count;
  final String icon;
  // ...
}

class SentenceSubtopic extends Equatable {
  final int subTopicId;
  final int topicId;
  final String titleEn;
  final String titleAr;
  // ...
}

class SentenceContent extends Equatable {
  final int id;
  final int subTopicId;
  final String grammarEn;
  final String sentenceEn;
  final String sentenceAr;
  final String? example;
  final String? titleEn;
  final String? answers;       // scrambled word options
  // ...
}
```

```dart
// ─── Repository ───

abstract class SentenceRepository {
  Future<Either<Failure, List<SentenceTopic>>> getTopicsForLevel(int levelId);
  Future<Either<Failure, List<SentenceSubtopic>>> getSubtopics(int topicId);
  Future<Either<Failure, List<SentenceContent>>> getContents(int subtopicId);
}
```

### 12.2 Presentation - Practice BLoC

```dart
// Events
class SubmitAnswer extends SentencePracticeEvent {
  final List<String> selectedWords;
  SubmitAnswer({required this.selectedWords});
}
class NextSentence extends SentencePracticeEvent {}

// State
class SentencePracticeLoaded extends SentencePracticeState {
  final List<SentenceContent> sentences;
  final int currentIndex;
  final List<String> scrambledWords;
  final List<String> selectedWords;
  final bool? isCorrect;
  // ...
}

// Bloc
class SentencePracticeBloc extends Bloc<SentencePracticeEvent, SentencePracticeState> {
  final GetSentenceContents getContents;
  final AudioManager audioManager;

  SentencePracticeBloc({ ... }) : super(SentencePracticeInitial()) {
    on<LoadSentences>((event, emit) async {
      emit(SentencePracticeLoading());
      final result = await getContents(SubtopicParams(subtopicId: event.subtopicId));
      result.fold(
        (f) => emit(SentencePracticeError(message: f.message)),
        (sentences) {
          final scrambled = _scrambleWords(sentences.first);
          emit(SentencePracticeLoaded(
            sentences: sentences,
            currentIndex: 0,
            scrambledWords: scrambled,
            selectedWords: [],
          ));
        },
      );
    });

    on<SubmitAnswer>((event, emit) {
      final current = (state as SentencePracticeLoaded);
      final sentence = current.sentences[current.currentIndex];
      final isCorrect = event.selectedWords.join(' ') == sentence.sentenceEn;
      emit(current.copyWith(isCorrect: isCorrect));
    });

    on<NextSentence>((event, emit) {
      final current = (state as SentencePracticeLoaded);
      final nextIndex = current.currentIndex + 1;
      if (nextIndex >= current.sentences.length) {
        emit(SentencePracticeCompleted(
          total: current.sentences.length,
          correct: /* count correct */,
        ));
      } else {
        emit(current.copyWith(
          currentIndex: nextIndex,
          scrambledWords: _scrambleWords(current.sentences[nextIndex]),
          selectedWords: [],
          isCorrect: null,
        ));
      }
    });
  }

  List<String> _scrambleWords(SentenceContent sentence) {
    final words = sentence.sentenceEn.split(' ')..shuffle();
    return words;
  }
}
```

---

## 13. Feature: Conversations

### 13.1 Domain

```dart
// ─── Entities ───

class ConversationBlock extends Equatable {
  final int id;
  final String title;
  final String titleAr;
  final int itemCount;
  final int level;
  // ...
}

class ConversationLesson extends Equatable {
  final int id;
  final int level;
  final int duration;        // seconds
  final String title;
  final String titleAr;
  final int blockId;
  // ...
}

class ConversationSentence extends Equatable {
  final int id;
  final int lessonId;
  final String character;     // "James", "Lisa"
  final int startSecond;
  final int endSecond;
  final String sentence;
  final String phonetic;      // "{Hello | həˈloʊ}."
  final String sentenceAr;
  // ...
}
```

```dart
// ─── Repository ───

abstract class ConversationRepository {
  Future<Either<Failure, List<ConversationBlock>>> getBlocksForLevel(int levelId);
  Future<Either<Failure, List<ConversationLesson>>> getLessons(int blockId);
  Future<Either<Failure, List<ConversationSentence>>> getSentences(int lessonId);
}
```

### 13.2 Presentation - Player BLoC

```dart
// Events
class LoadConversation extends ConversationPlayerEvent { final int lessonId; ... }
class PlayPause extends ConversationPlayerEvent {}
class SeekToSentence extends ConversationPlayerEvent { final int sentenceId; ... }
class ToggleArabic extends ConversationPlayerEvent {}
class TogglePhonetic extends ConversationPlayerEvent {}

// State
class ConversationPlayerLoaded extends ConversationPlayerState {
  final ConversationLesson lesson;
  final List<ConversationSentence> sentences;
  final int? activeSentenceId;
  final bool isPlaying;
  final Duration position;
  final bool showArabic;
  final bool showPhonetic;
  // ...
}

// Bloc
class ConversationPlayerBloc extends Bloc<ConversationPlayerEvent, ConversationPlayerState> {
  final GetConversationSentences getSentences;
  final AudioManager audioManager;
  StreamSubscription<Duration>? _positionSub;

  ConversationPlayerBloc({ ... }) : super(ConversationPlayerInitial()) {
    on<LoadConversation>((event, emit) async {
      emit(ConversationPlayerLoading());
      final result = await getSentences(LessonParams(lessonId: event.lessonId));

      await result.fold(
        (f) async => emit(ConversationPlayerError(message: f.message)),
        (sentences) async {
          emit(ConversationPlayerLoaded(
            lesson: /* ... */,
            sentences: sentences,
            isPlaying: false,
            position: Duration.zero,
            showArabic: true,
            showPhonetic: true,
          ));

          // Listen to audio position to highlight active sentence
          _positionSub = audioManager.positionStream.listen((position) {
            final seconds = position.inSeconds;
            final active = sentences.cast<ConversationSentence?>().firstWhere(
              (s) => seconds >= s!.startSecond && seconds <= s.endSecond,
              orElse: () => null,
            );
            if (active != null) {
              add(_UpdateActiveSentence(sentenceId: active.id));
            }
          });
        },
      );
    });

    on<PlayPause>((event, emit) async {
      final current = state as ConversationPlayerLoaded;
      if (current.isPlaying) {
        await audioManager.pause();
      } else {
        final voice = 'us_male'; // from settings
        final url = CdnConfig.conversationAudio(current.lesson.id, voice);
        await audioManager.play(url);
      }
      emit(current.copyWith(isPlaying: !current.isPlaying));
    });

    on<SeekToSentence>((event, emit) async {
      final current = state as ConversationPlayerLoaded;
      final sentence = current.sentences.firstWhere((s) => s.id == event.sentenceId);
      await audioManager.seek(Duration(seconds: sentence.startSecond));
    });

    on<ToggleArabic>((event, emit) {
      final current = state as ConversationPlayerLoaded;
      emit(current.copyWith(showArabic: !current.showArabic));
    });

    on<TogglePhonetic>((event, emit) {
      final current = state as ConversationPlayerLoaded;
      emit(current.copyWith(showPhonetic: !current.showPhonetic));
    });
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}
```

---

## 14. Feature: Word List

### 14.1 Domain

```dart
class WordListEntry extends Equatable {
  final int id;
  final String word;
  final String wordAr;
  final String pronunciation;
  final String example;
  final String level;
  // ...
}

abstract class WordListRepository {
  Future<Either<Failure, List<WordListEntry>>> getByLevel(String level, {int offset, int limit});
  Future<Either<Failure, List<WordListEntry>>> search(String query, String level);
  Future<Either<Failure, void>> addToMyWords(WordListEntry entry);
  Future<Either<Failure, void>> removeFromMyWords(int id);
}
```

### 14.2 Presentation

```dart
// Bloc supports paginated loading
class WordListBloc extends Bloc<WordListEvent, WordListState> {
  on<LoadWordList>((event, emit) async {
    final result = await getByLevel(WordListParams(
      level: event.level, offset: 0, limit: 50,
    ));
    // ...
  });

  on<LoadMoreWords>((event, emit) async {
    final current = state as WordListLoaded;
    final result = await getByLevel(WordListParams(
      level: current.level,
      offset: current.words.length,
      limit: 50,
    ));
    result.fold(
      (f) => emit(current.copyWith(hasReachedMax: true)),
      (newWords) => emit(current.copyWith(
        words: [...current.words, ...newWords],
        hasReachedMax: newWords.length < 50,
      )),
    );
  });

  on<SearchWords>((event, emit) async {
    final result = await search(SearchParams(query: event.query, level: event.level));
    // ...
  });
}
```

---

## 15. Feature: Dashboard

### 15.1 Domain

```dart
class DashboardStats extends Equatable {
  final int currentStreak;
  final int dailyCompleted;
  final int dailyGoal;
  final Map<String, double> moduleProgress; // {'phonetics': 0.45, 'grammar': 0.30, ...}
  final CefrLevel currentLevel;
  // ...
}

abstract class DashboardRepository {
  Future<DashboardStats> getStats();
}

@injectable
class GetDashboardStats {
  final DashboardRepository _repository;
  GetDashboardStats(this._repository);

  Future<Either<AppException, DashboardStats>> execute() async {
    try {
      final result = await _repository.getStats();
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
```

### 15.2 Presentation

```dart
@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStats _getStats;

  DashboardBloc(this._getStats) : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
  }

  Future<void> _onLoad(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    final result = await _getStats.execute();
    result.fold(
      (exception) => emit(DashboardError(message: exception.toString())),
      (stats) => emit(DashboardLoaded(stats: stats)),
    );
  }
}
```

---

## 16. Feature: Onboarding

```dart
// Simple Cubit (no domain layer needed)

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final SharedPreferences _prefs;
  static const int totalPages = 3;

  OnboardingCubit(this._prefs) : super(const OnboardingState());

  void nextPage()     => emit(state.copyWith(currentPage: state.currentPage + 1));
  void previousPage() => emit(state.copyWith(currentPage: state.currentPage - 1));
  void selectLevel(CefrLevel level) => emit(state.copyWith(selectedLevel: level));

  Future<void> completeOnboarding() async {
    final level = state.selectedLevel ?? CefrLevel.a1;
    await _prefs.setString(AppConstants.prefSelectedLevel, level.key);
    await _prefs.setBool(AppConstants.prefOnboardingComplete, true);
    emit(state.copyWith(selectedLevel: level, isCompleted: true));
  }
}
```

---

## 17. Feature: Profile & Settings

```dart
// ─── Profile Cubit ───

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfile _getUserProfile;

  ProfileCubit(this._getUserProfile) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await _getUserProfile.execute();
    result.fold(
      (exception) => emit(ProfileError(message: exception.toString())),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }
}

// ─── Settings Cubit ───

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(SettingsState.fromPrefs(_prefs));

  void setLevel(String level) {
    _prefs.setString('selected_level', level);
    emit(state.copyWith(level: level));
  }

  void setDailyGoal(int goal) {
    _prefs.setInt('daily_goal', goal);
    emit(state.copyWith(dailyGoal: goal));
  }

  void setVoiceAccent(VoiceAccent accent) {
    _prefs.setString('voice_accent', accent.key);
    emit(state.copyWith(voiceAccent: accent));
  }

  void setLocale(Locale locale) {
    _prefs.setString('locale', locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  void toggleDarkMode() {
    final isDark = !state.isDarkMode;
    _prefs.setBool('dark_mode', isDark);
    emit(state.copyWith(isDarkMode: isDark));
  }
}
```

---

## 18. Shared / Common

### 18.1 Voice Accent Enum

```dart
// lib/shared/enums/voice_accent.dart

enum VoiceAccent {
  usMale('us_male', 'US Male'),
  usFemale('us_female', 'US Female'),
  ukMale('uk_male', 'UK Male'),
  ukFemale('uk_female', 'UK Female');

  final String key;
  final String label;
  const VoiceAccent(this.key, this.label);
}
```

### 18.2 Common Params

```dart
// lib/core/usecases/params.dart

class LevelParams extends Equatable {
  final int levelId;
  const LevelParams({required this.levelId});
  @override List<Object?> get props => [levelId];
}

class TopicParams extends Equatable {
  final int topicId;
  const TopicParams({required this.topicId});
  @override List<Object?> get props => [topicId];
}

class SubtopicParams extends Equatable {
  final int subtopicId;
  const SubtopicParams({required this.subtopicId});
  @override List<Object?> get props => [subtopicId];
}

class LessonParams extends Equatable {
  final int lessonId;
  const LessonParams({required this.lessonId});
  @override List<Object?> get props => [lessonId];
}

class SearchParams extends Equatable {
  final String query;
  const SearchParams({required this.query});
  @override List<Object?> get props => [query];
}
```

---

## 19. Navigation

```dart
// lib/core/router/app_router.dart

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final prefs = sl<SharedPreferences>();
      final isOnboarded = prefs.getBool('is_onboarded') ?? false;
      if (!isOnboarded && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),

          // Phonetics
          GoRoute(path: '/phonetics', builder: (_, __) => const PhoneticsCategoriesScreen()),
          GoRoute(path: '/phonetics/:catId', builder: (_, s) =>
            PhoneticsTopicsScreen(categoryId: int.parse(s.pathParameters['catId']!))),
          GoRoute(path: '/phonetics/:catId/:topicId', builder: (_, s) =>
            PhoneticsDetailScreen(topicId: int.parse(s.pathParameters['topicId']!))),

          // Grammar
          GoRoute(path: '/grammar', builder: (_, __) => const GrammarTopicsScreen()),
          GoRoute(path: '/grammar/:topicId', builder: (_, s) =>
            GrammarSubtopicsScreen(topicId: int.parse(s.pathParameters['topicId']!))),
          GoRoute(path: '/grammar/:topicId/:subId', builder: (_, s) =>
            GrammarLessonScreen(subtopicId: int.parse(s.pathParameters['subId']!))),
          GoRoute(path: '/grammar/:topicId/:subId/test', builder: (_, s) =>
            GrammarTestScreen(subtopicId: int.parse(s.pathParameters['subId']!))),

          // Vocabulary
          GoRoute(path: '/vocabulary', builder: (_, __) => const VocabularyTopicsScreen()),
          GoRoute(path: '/vocabulary/:topicId', builder: (_, s) =>
            VocabularySubtopicsScreen(topicId: int.parse(s.pathParameters['topicId']!))),
          GoRoute(path: '/vocabulary/:topicId/:subId', builder: (_, s) =>
            VocabularyListScreen(subtopicId: int.parse(s.pathParameters['subId']!))),

          // Sentences
          GoRoute(path: '/sentences', builder: (_, __) => const SentenceTopicsScreen()),
          GoRoute(path: '/sentences/:topicId', builder: (_, s) =>
            SentenceSubtopicsScreen(topicId: int.parse(s.pathParameters['topicId']!))),
          GoRoute(path: '/sentences/:topicId/:subId', builder: (_, s) =>
            SentencePracticeScreen(subtopicId: int.parse(s.pathParameters['subId']!))),

          // Conversations
          GoRoute(path: '/conversations', builder: (_, __) => const ConversationBlocksScreen()),
          GoRoute(path: '/conversations/:blockId', builder: (_, s) =>
            ConversationLessonsScreen(blockId: int.parse(s.pathParameters['blockId']!))),
          GoRoute(path: '/conversations/:blockId/:lessonId', builder: (_, s) =>
            ConversationPlayerScreen(lessonId: int.parse(s.pathParameters['lessonId']!))),

          // Word List
          GoRoute(path: '/wordlist', builder: (_, __) => const WordListLevelsScreen()),
          GoRoute(path: '/wordlist/:level', builder: (_, s) =>
            WordListSearchScreen(level: s.pathParameters['level']!)),

          // Profile & Settings
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
}
```

---

## 20. Localization & RTL

```dart
// lib/app.dart

MaterialApp.router(
  locale: context.watch<SettingsCubit>().state.locale,
  supportedLocales: const [Locale('en'), Locale('ar')],
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  // ...
)
```

**Bilingual content** (DB already has both languages):
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(topic.title, style: BayanTypography.titleLarge),
    Text(topic.titleAr, style: BayanTypography.bodyMedium.copyWith(
      fontFamily: 'Noto Sans Arabic',
      color: BayanColors.textSecondary,
    )),
  ],
)
```

**Mixed direction rows:**
```dart
Row(
  textDirection: TextDirection.ltr,
  children: [
    Text(word.name),
    const Spacer(),
    Text(word.nameAr),
  ],
)
```

---

## 21. Gamification & Progress

### 21.1 Progress Tables (add to DB)

```sql
CREATE TABLE user_progress (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  module        TEXT NOT NULL,
  item_id       INTEGER NOT NULL,
  item_type     TEXT NOT NULL,
  status        TEXT NOT NULL DEFAULT 'not_started',
  score         INTEGER DEFAULT 0,
  completed_at  TEXT,
  UNIQUE(module, item_id, item_type)
);

CREATE TABLE user_stats (
  id              INTEGER PRIMARY KEY DEFAULT 1,
  current_streak  INTEGER DEFAULT 0,
  longest_streak  INTEGER DEFAULT 0,
  last_active     TEXT,
  total_xp        INTEGER DEFAULT 0,
  daily_completed INTEGER DEFAULT 0,
  daily_goal      INTEGER DEFAULT 6
);
```

### 21.2 Achievement Badges

| Badge | Condition | Icon |
|---|---|---|
| First Step | Complete 1 lesson | Seed |
| Week Warrior | 7-day streak | Fire |
| Phonetics Pro | All phonetics done | Microphone |
| Grammar Guru | All grammar tests | Pencil |
| Word Collector | Learn 500 words | Books |
| Conversation King | 50 conversations | Crown |
| Polyglot | All A2 content | Trophy |
| Streak Master | 30-day streak | Diamond |

---

## 22. Performance Optimization

| Area | Strategy |
|---|---|
| **Database** | Pre-indexed. Pagination for word_list (50/page) |
| **Audio** | `LockCachingAudioSource` for offline cache. 1 player instance |
| **Images** | `CachedNetworkImage` with `memCacheWidth`. Shimmer placeholders |
| **Lists** | `ListView.builder` everywhere. `AutomaticKeepAliveClientMixin` for tabs |
| **BLoC** | `Equatable` states prevent unnecessary rebuilds |
| **Startup** | DB copy only on first launch. Lazy DI registration |

---

## 23. Testing Strategy

### Unit Tests (Domain & Data)
```
test/
├── features/
│   ├── phonetics/
│   │   ├── domain/usecases/get_phonetic_categories_test.dart
│   │   ├── data/datasources/phonetic_local_datasource_test.dart
│   │   └── data/repositories/phonetic_repository_impl_test.dart
│   ├── grammar/...
│   ├── vocabulary/...
│   └── ...
├── core/
│   ├── database/database_helper_test.dart
│   └── network/cdn_config_test.dart
```

### BLoC Tests
```dart
// Using bloc_test + mocktail
blocTest<PhoneticDetailBloc, PhoneticDetailState>(
  'emits [Loading, Loaded] when LoadPhoneticDetail succeeds',
  build: () {
    when(() => mockGetSections(any())).thenAnswer(
      (_) async => Right(testSections),
    );
    return PhoneticDetailBloc(getSections: mockGetSections, audioManager: mockAudio);
  },
  act: (bloc) => bloc.add(LoadPhoneticDetail(topicId: 1, accent: 'us')),
  expect: () => [
    isA<PhoneticDetailLoading>(),
    isA<PhoneticDetailLoaded>(),
  ],
);
```

### Widget Tests
- Each shared widget with mock BLoC
- Screen rendering with `BlocProvider.value`

### Integration Tests
- Full flow: Onboarding -> Dashboard -> Module -> Lesson
- Audio playback lifecycle
- Progress persistence across app restart

---

## 24. Release & Deployment

### Build Checklist

```
[ ] learn_db.db in assets/databases/
[ ] CloudFront domain in cdn_config.dart
[ ] App icons (1024x1024)
[ ] Splash screen
[ ] Bundle ID: com.bayan.english
[ ] Min iOS 15.0 | Android API 24
[ ] ProGuard for SQLite (Android)
[ ] Store metadata (EN + AR)
[ ] Privacy policy
[ ] Screenshots: iPhone 15, Pixel 8, iPad
```

### App Size

| Component | Size |
|---|---|
| Flutter engine | ~5 MB |
| App code | ~3 MB |
| SQLite database | ~7.5 MB |
| Fonts | ~1 MB |
| Icons/assets | ~2 MB |
| **Total** | **~18 MB** |

Audio + images stream from CloudFront.

---

## 25. Implementation Phases

| Phase | Scope |
|---|---|
| **Phase 1** | Core: DI, DB helper, theme, router, base classes |
| **Phase 2** | Onboarding + Dashboard (BLoC + screen) |
| **Phase 3** | Phonetics (full clean arch: domain → data → presentation) |
| **Phase 4** | Vocabulary + Word List |
| **Phase 5** | Grammar (complex nested rendering) |
| **Phase 6** | Sentences + Practice mode |
| **Phase 7** | Conversations + Audio sync player |
| **Phase 8** | Profile, Settings, Gamification |
| **Phase 9** | RTL polish, Dark mode, Animations |
| **Phase 10** | Testing + Store submission |

---



### 26. Colors:
```
surface: '#f8f9ff'
surface-dim: '#cbdbf5'
surface-bright: '#f8f9ff'
surface-container-lowest: '#ffffff'
surface-container-low: '#eff4ff'
surface-container: '#e5eeff'
surface-container-high: '#dce9ff'
surface-container-highest: '#d3e4fe'
on-surface: '#0b1c30'
on-surface-variant: '#424754'
inverse-surface: '#213145'
inverse-on-surface: '#eaf1ff'
outline: '#727785'
outline-variant: '#c2c6d6'
surface-tint: '#005ac2'
primary: '#0058be'
on-primary: '#ffffff'
primary-container: '#2170e4'
on-primary-container: '#fefcff'
inverse-primary: '#adc6ff'
secondary: '#006c49'
on-secondary: '#ffffff'
secondary-container: '#6cf8bb'
on-secondary-container: '#00714d'
tertiary: '#825100'
on-tertiary: '#ffffff'
tertiary-container: '#a36700'
on-tertiary-container: '#fffbff'
error: '#ba1a1a'
on-error: '#ffffff'
error-container: '#ffdad6'
on-error-container: '#93000a'
primary-fixed: '#d8e2ff'
primary-fixed-dim: '#adc6ff'
on-primary-fixed: '#001a42'
on-primary-fixed-variant: '#004395'
secondary-fixed: '#6ffbbe'
secondary-fixed-dim: '#4edea3'
on-secondary-fixed: '#002113'
on-secondary-fixed-variant: '#005236'
tertiary-fixed: '#ffddb8'
tertiary-fixed-dim: '#ffb95f'
on-tertiary-fixed: '#2a1700'
on-tertiary-fixed-variant: '#653e00'
background: '#f8f9ff'
on-background: '#0b1c30'
surface-variant: '#d3e4fe'
typography:
display-lg:
fontFamily: Be Vietnam Pro
fontSize: 32px
fontWeight: '700'
lineHeight: 40px
letterSpacing: -0.02em
headline-lg:
fontFamily: Be Vietnam Pro
fontSize: 24px
fontWeight: '600'
lineHeight: 32px
headline-md:
fontFamily: Be Vietnam Pro
fontSize: 20px
fontWeight: '600'
lineHeight: 28px
body-lg:
fontFamily: Inter
fontSize: 18px
fontWeight: '400'
lineHeight: 28px
body-md:
fontFamily: Inter
fontSize: 16px
fontWeight: '400'
lineHeight: 24px
body-sm:
fontFamily: Inter
fontSize: 14px
fontWeight: '400'
lineHeight: 20px
label-lg:
fontFamily: Inter
fontSize: 14px
fontWeight: '600'
lineHeight: 20px
letterSpacing: 0.01em
label-md:
fontFamily: Inter
fontSize: 12px
fontWeight: '500'
lineHeight: 16px
headline-lg-mobile:
fontFamily: Be Vietnam Pro
fontSize: 22px
fontWeight: '600'
lineHeight: 28px
rounded:
sm: 0.25rem
DEFAULT: 0.5rem
md: 0.75rem
lg: 1rem
xl: 1.5rem
full: 9999px
spacing:
base: 4px
xs: 4px
sm: 8px
md: 16px
lg: 24px
xl: 32px
container-padding: 20px
card-gap: 16px
```
> **Bayan English** — Master English, Your Way.
> أتقن الإنجليزية بطريقتك
