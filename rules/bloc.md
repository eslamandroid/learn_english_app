# BLoC Rules

- Use BLoC only
- No GetX

## State
- Immutable
- Use copyWith

## Performance
- Avoid emitting on every change
- Use buildWhen

## API Calls
- Prevent duplicate calls
- Cancel previous requests

## Pattern
- Event → UseCase → Result → State