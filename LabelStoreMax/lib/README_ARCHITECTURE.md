Module layout

- core/: cross-cutting concerns (errors, usecases base, utils)
- features/: vertical slices (articles, chat, onboarding, auth, iap)
- data/: datasources, repositories implementations
- domain/: entities, repository contracts, usecases

This README documents the layered modules introduced for future refactors. Existing Nylo pages and providers remain functional while new features adopt the layered structure incrementally.

