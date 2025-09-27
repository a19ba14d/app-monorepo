# OneKey UI Mock (Flutter)

This standalone Flutter project scaffolds the UI/UX-only reimplementation of the OneKey wallet mobile app. It follows the migration plan in [`docs/flutter-ui-migration-plan.md`](../docs/flutter-ui-migration-plan.md) and focuses exclusively on visual parity backed by mock data.

## Project Goals
- Reproduce every React Native screen with Flutter widgets while maintaining navigation structure, theming, and animations.
- Replace all backend integrations with deterministic mock repositories and scenario toggles for QA.
- Provide a modular architecture so real services can replace mocks later via dependency injection.

## Structure Overview
```
lib/
  app.dart             # Root widget & router integration
  bootstrap.dart       # Loads mock fixtures and readiness gate
  router/              # go_router configuration mirroring RN stacks
  theme/               # Design tokens, color schemes, typography
  features/            # Feature-first directories (onboarding, home, ...)
  mocks/               # Mock data fixtures and repositories
  shared/widgets/      # Design system primitives mapped from RN components
```

## Getting Started
1. Install Flutter 3.x (with Dart 3.x) and run `flutter pub get`.
2. (Optional) Generate model code with `dart run build_runner build --delete-conflicting-outputs`.
3. Launch the app with `flutter run` and use the scenario drawer to switch between mock datasets (to be implemented).

## Next Steps
- Flesh out feature modules following the prioritized roadmap in the migration plan.
- Implement mock repositories and scenario registry under `lib/mocks/`.
- Build widget gallery & parity verification utilities.
