# Create Feature From cURL APIs

Create or update a Flutter feature using the provided cURL requests.

For each cURL:
1. Parse method, endpoint, headers, query params, and body.
2. Create DataSource method.
3. Create request/input model if needed.
4. Create response DTO.
5. Create mapper DTO → Domain Model.
6. Add repository abstract method.
7. Implement repository method.
8. Add use case.
9. Connect to BLoC/Cubit.
10. Keep UI clean and render-only.

Rules:
- Use Clean Architecture.
- Use BLoC.
- Use Dio.
- Use Either<AppException, T>.
- Use CancellationToken.
- Do not expose DTOs to UI.
- Do not put API logic in BLoC or widgets.
- Follow existing project naming and API client style.