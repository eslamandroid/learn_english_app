
---

# 📦 2. rules/architecture.md

```md
# Architecture Rules

- Follow Clean Architecture strictly
- Each feature has: domain, data, presentation

## Domain
- Models are pure
- Repository is abstract
- UseCases return Either<AppException, T>

## Data
- DTO != Model
- Use mapper extensions
- Repository implements domain contract

## Presentation
- Bloc handles logic
- UI only renders