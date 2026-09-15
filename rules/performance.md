# Performance Rules

- Avoid unnecessary rebuilds
- Use BlocSelector when possible
- Use const widgets
- Do not create controllers inside build
- Cache values in Cubit
- Avoid heavy logic in UI

## Anti-patterns
- setState + API call ❌
- emit on every keystroke ❌