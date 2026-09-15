# Create Feature Template

Create a complete feature named: {{feature_name}}

Follow strictly:
- Clean Architecture
- BLoC pattern
- Feature-based structure

---

## 1. Folder Structure

Create:

feature/{{feature_name}}/
- domain/
- data/
- presentation/

---

## 2. Domain Layer

Create:

### Model
- {{feature_name}}_model.dart

### Repository (abstract)
- {{feature_name}}_repository.dart

### UseCases
- get_{{feature_name}}_usecase.dart
- create_{{feature_name}}_usecase.dart

Rules:
- Use Either<AppException, T>
- Use @Injectable()
- Accept CancellationToken

---

## 3. Data Layer

Create:

### DTO
- {{feature_name}}_dto.dart

### Remote DataSource
- {{feature_name}}_remote_datasource.dart

### Repository Impl
- {{feature_name}}_repository_impl.dart

### Mapper
- extension mapper from DTO → Model

Rules:
- Use Dio
- Handle errors
- Map data properly

---

## 4. Presentation Layer

Create:

### Bloc
- {{feature_name}}_bloc.dart
- {{feature_name}}_event.dart
- {{feature_name}}_state.dart

### Screen
- {{feature_name}}_screen.dart

### Widgets
- {{feature_name}}_item.dart

Rules:
- Bloc handles logic
- UI only renders
- Use buildWhen

---

## 5. Requirements

- Add loading state
- Add error handling
- Prevent duplicate API calls
- Use cancellation

---

## 6. Output

- Generate full working code
- Follow project rules (AGENTS.md)
- Keep code clean and minimal