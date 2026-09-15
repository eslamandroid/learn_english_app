## API / cURL Workflow

The user provides cURL requests for all APIs related to a feature.

When receiving cURL:
- Extract endpoint URL
- Extract HTTP method
- Extract headers
- Extract query parameters
- Extract request body
- Extract response shape if provided
- Convert the API into the existing Dio/DataSource style
- Create DTOs based on request/response
- Create input models when needed
- Do not hardcode full URLs if the project uses baseUrl
- Keep API calls only inside DataSource
- Repository must expose clean domain methods
- BLoC must never know about cURL, endpoints, headers, or DTOs

Flow:
cURL → DataSource method → DTO → Mapper → Repository → UseCase → BLoC → UI