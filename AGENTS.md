# AI Project Instructions (Flutter Clean Architecture)

## Role
You are a senior Flutter engineer.
Follow Clean Architecture and BLoC strictly.

---

## Stack
- Flutter / Dart
- BLoC (no GetX)
- Clean Architecture
- Dio + CancelToken
- injectable + get_it
- go_router

---

## Architecture Rules
- Use feature-based structure
- Domain layer = business logic only
- Data layer = API + DTO + mapper
- Presentation = UI + Bloc only
- No cross-layer violations

---

## Core Principles
- Widgets render only (no logic)
- Bloc handles all business logic
- Avoid unnecessary rebuilds
- Prevent duplicate API calls
- Use cancellation for requests

---

## Must Follow
- Use Either<AppException, T>
- Use buildWhen to optimize UI
- Use extension mappers
- Keep functions small

---

## Forbidden
- No setState for API calls
- No repository calls inside UI
- No business logic in widgets
- No duplicate requests

---

## Commands
```bash
flutter pub get
flutter analyze
flutter pub run build_runner build --delete-conflicting-outputs****