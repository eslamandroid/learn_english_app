# Widget Rules

## File layout

- **One widget per file** under `lib/features/<feature>/presentation/widgets/`.
- Filename is `snake_case` of the widget class
  (e.g. `GrammarLessonLoadedBody` → `grammar_lesson_loaded_body.dart`).
- **No private widget classes inside screen files.** Anything `extends StatelessWidget`
  or `extends StatefulWidget` that lives beside the screen — `_Body`, `_Header`,
  `_NextRuleBar`, etc. — must move into its own file under `widgets/` with a
  public name.
- Tiny named helpers used *only* inside one widget (private painters,
  single-use `_Row`/`_Pill` sub-classes called by exactly one outer widget)
  may stay inside that widget's file as `_PrivateName`. They never leak into
  the screen file.
- Cross-feature widgets go in `lib/shared/widgets/` (already true today for
  `ErrorStateView`, `EmptyStateView`, `BayanAppBar`, etc.).

## Allowed inside a widget
- `StatelessWidget` preferred; `StatefulWidget` only when local UI state is
  genuinely necessary.
- Pure presentation — wiring callbacks up, rendering data passed in via the
  constructor.
- Reading bloc state via `BlocBuilder` / `context.watch` / `context.read`.
- `_buildHeader()` / `_buildBody()` helper methods inside the widget class are
  fine.

## Not allowed inside a widget
- Direct `SharedPreferences` reads (`getIt<SharedPreferences>()`). Route prefs
  through a use case + bloc — see `rules/bloc.md`.
- Direct `getIt<UseCase>()` reads in `FutureBuilder` / `StreamBuilder`. Always
  go through a bloc.
- API/database calls, business logic, persistence.
- Coordinating multiple blocs by hand (use one bloc that depends on the use
  cases it needs).

## Screen-file rule of thumb
Each screen file should be ~one `StatelessWidget` that builds a
`Scaffold(appBar:, body:, bottomNavigationBar:)`. Everything else — the loaded
body, the bottom action bar, section headings, list rows — lives in its own
widget file. If a screen file grows past ~120 lines or holds more than one
`class … extends ...Widget`, extract.

## Pattern
Widget → Event → Bloc → State → UI
